
from uuid import UUID

import jwt
from fastapi import Depends, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from app.core.security import decode_token
from app.db.session import get_db
from app.services.auth_service import AuthService


bearer_scheme = HTTPBearer(auto_error=False)


def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
    db: Session = Depends(get_db),
):
    credentials_exception = HTTPException(
        status_code=401,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )

    if credentials is None:
        raise credentials_exception

    try:
        token = credentials.credentials
        payload = decode_token(token)

        if payload.get("type") != "access":
            raise credentials_exception

        user_id = UUID(payload["sub"])

    except (jwt.InvalidTokenError, ValueError, TypeError, KeyError):
        raise credentials_exception

    try:
        return AuthService(db).get_current_user(user_id)
    except ValueError:
        raise credentials_exception
