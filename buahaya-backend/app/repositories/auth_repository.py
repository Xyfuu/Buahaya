from uuid import UUID
from sqlalchemy import or_, select
from sqlalchemy.orm import Session
from app.models.user import User

class AuthRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_by_email(self, email: str) -> User | None:
        statement = select(User).where(User.email == email)
        return self.db.scalar(statement)

    def get_by_username(self, username: str) -> User | None:
        statement = select(User).where(User.username == username)
        return self.db.scalar(statement)

    def get_by_identifier(self, identifier: str) -> User | None:
        statement = select(User).where(
            or_(
                User.email == identifier,
                User.username == identifier,
            )
        )
        return self.db.scalar(statement)

    def create_user(self, username: str, email: str, password_hash: str) -> User:
        user = User(username=username, email=email, password_hash=password_hash)

        self.db.add(user)
        self.db.flush()

        return user

    def get_by_id(self, user_id: UUID) -> User | None:
        statement = select(User).where(
            User.id == user_id
        )
        return self.db.scalar(statement)
