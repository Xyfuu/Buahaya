
from datetime import datetime, timedelta, timezone
from uuid import UUID

import jwt
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.security import (
    create_access_token,
    create_refresh_token,
    decode_token,
    hash_password,
    hash_refresh_token,
    verify_password,
)
from app.models.auth_session import AuthSession
from app.repositories.auth_repository import AuthRepository
from app.repositories.auth_session_repository import (
    AuthSessionRepository,
)
from app.schemas.auth import (
    AuthResponse,
    LoginRequest,
    RegisterRequest,
    TokenResponse,
)
from app.schemas.user import UserResponse


class AuthService:

    def __init__(self, db: Session):
        self.db = db
        self.repository = AuthRepository(db)
        self.session_repository = AuthSessionRepository(db)

    def _create_session(self, user_id: UUID) -> TokenResponse:
        access_token = create_access_token(str(user_id))
        refresh_token = create_refresh_token(str(user_id))

        expires_at = datetime.now(timezone.utc) + timedelta(
            days=settings.REFRESH_TOKEN_EXPIRE_DAYS
        )

        self.session_repository.create(
            user_id=user_id,
            refresh_token_hash=hash_refresh_token(refresh_token),
            expires_at=expires_at,
        )

        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        )

    def register(self, data: RegisterRequest) -> AuthResponse:
        email = str(data.email).strip().lower()
        username = data.username.strip()

        if self.repository.get_by_email(email):
            raise ValueError("Email is already registered")

        if self.repository.get_by_username(username):
            raise ValueError("Username is already taken")

        try:
            user = self.repository.create_user(
                username=username,
                email=email,
                password_hash=hash_password(data.password),
            )

            self.db.flush()

            tokens = self._create_session(user.id)

            self.db.commit()
            self.db.refresh(user)

            return AuthResponse(
                user=UserResponse.model_validate(user),
                tokens=tokens,
            )

        except Exception:
            self.db.rollback()
            raise

    def login(self, data: LoginRequest) -> AuthResponse:
        identifier = data.identifier.strip()

        if "@" in identifier:
            identifier = identifier.lower()

        user = self.repository.get_by_identifier(identifier)

        if (
            not user
            or not verify_password(
                data.password,
                user.password_hash,
            )
            or not user.is_active
        ):
            raise ValueError("Invalid username/email or password")

        try:
            tokens = self._create_session(user.id)

            self.db.commit()

            return AuthResponse(
                user=UserResponse.model_validate(user),
                tokens=tokens,
            )

        except Exception:
            self.db.rollback()
            raise

    def refresh(self, refresh_token: str) -> TokenResponse:
        try:
            payload = decode_token(refresh_token)
        except jwt.InvalidTokenError:
            raise ValueError("Invalid or expired refresh token")

        if payload.get("type") != "refresh":
            raise ValueError("Invalid refresh token type")

        try:
            user_id = UUID(payload["sub"])
        except (ValueError, TypeError, KeyError):
            raise ValueError("Invalid refresh token subject")

        try:
            session = self.session_repository.get_active_by_hash(
                hash_refresh_token(refresh_token)
            )

            if not session or session.user_id != user_id:
                raise ValueError("Refresh session is invalid or revoked")

            user = self.repository.get_by_id(user_id)

            if not user or not user.is_active:
                self.session_repository.revoke(session)
                self.db.commit()
                raise ValueError("User is inactive or unavailable")

            # Revoke the old refresh token before creating a new one.
            self.session_repository.revoke(session)

            tokens = self._create_session(user.id)

            self.db.commit()

            return tokens

        except Exception:
            self.db.rollback()
            raise

    def logout(self, refresh_token: str) -> None:
        try:
            payload = decode_token(refresh_token)
        except jwt.InvalidTokenError:
            raise ValueError("Invalid or expired refresh token")

        if payload.get("type") != "refresh":
            raise ValueError("Invalid refresh token type")

        try:
            session = self.session_repository.get_active_by_hash(
                hash_refresh_token(refresh_token)
            )

            if not session:
                raise ValueError("Refresh session is invalid or revoked")

            self.session_repository.revoke(session)
            self.db.commit()

        except Exception:
            self.db.rollback()
            raise

    def get_current_user(self, user_id: UUID):
        user = self.repository.get_by_id(user_id)

        if not user or not user.is_active:
            raise ValueError("User not found or inactive")

        return UserResponse.model_validate(user)