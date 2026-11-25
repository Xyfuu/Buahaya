from datetime import datetime, timezone
from uuid import UUID
from sqlalchemy import select
from sqlalchemy.orm import Session
from app.models.auth_session import AuthSession


class AuthSessionRepository:
    def __init__(self, db: Session):
        self.db = db

    def create(
        self,
        user_id: UUID,
        refresh_token_hash: str,
        expires_at: datetime,
    ) -> AuthSession:
        session = AuthSession(
            user_id=user_id,
            refresh_token_hash=refresh_token_hash,
            expires_at=expires_at,
        )

        self.db.add(session)
        self.db.flush()

        return session

    def get_active_by_hash(
        self,
        token_hash: str,
    ) -> AuthSession | None:
        now = datetime.now(timezone.utc)

        statement = select(AuthSession).where(
            AuthSession.refresh_token_hash == token_hash,
            AuthSession.revoked_at.is_(None),
            AuthSession.expires_at > now,
        ).with_for_update()

        return self.db.scalar(statement)

    def revoke(self, session: AuthSession) -> None:
        session.revoked_at = datetime.now(timezone.utc)

    def revoke_all_for_user(self, user_id: UUID) -> None:
        now = datetime.now(timezone.utc)

        statement = select(AuthSession).where(
            AuthSession.user_id == user_id,
            AuthSession.revoked_at.is_(None),
        )

        sessions = self.db.scalars(statement).all()

        for session in sessions:
            session.revoked_at = now
