
from uuid import UUID

from sqlalchemy import select, delete
from sqlalchemy.dialects.postgresql import insert
from sqlalchemy.orm import Session

from app.models.device_token import DeviceToken


class DeviceTokenRepository:
    def __init__(self, db: Session):
        self.db = db

    def upsert(
        self,
        user_id: UUID,
        token: str,
        platform: str,
    ):
        statement = insert(DeviceToken).values(
            user_id=user_id,
            token=token,
            platform=platform,
        )

        statement = statement.on_conflict_do_update(
            index_elements=[DeviceToken.token],
            set_={
                "user_id": user_id,
                "platform": platform,
                "updated_at": statement.excluded.updated_at,
            },
        )

        self.db.execute(statement)

    def get_tokens_by_user(self, user_id: UUID):
        return list(
            self.db.scalars(
                select(DeviceToken).where(
                    DeviceToken.user_id == user_id
                )
            ).all()
        )

    def delete_token(self, user_id: UUID, token: str):
        result = self.db.execute(
            delete(DeviceToken).where(
                DeviceToken.user_id == user_id,
                DeviceToken.token == token,
            )
        )

        return result.rowcount
