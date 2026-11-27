
from uuid import UUID

from sqlalchemy.orm import Session

from app.repositories.device_token_repository import (
    DeviceTokenRepository,
)


class DeviceTokenService:
    def __init__(self, db: Session):
        self.db = db
        self.repository = DeviceTokenRepository(db)

    def register_token(self, user_id: UUID, token: str, platform: str):
        try:
            self.repository.upsert(
                user_id=user_id,
                token=token.strip(),
                platform=platform,
            )

            self.db.commit()

            return {"message": "Device token registered successfully"}

        except Exception:
            self.db.rollback()
            raise

    def unregister_token(self, user_id: UUID, token: str):
        try:
            deleted = self.repository.delete_token(
                user_id=user_id,
                token=token.strip(),
            )

            self.db.commit()

            return {
                "message": (
                    "Device token unregistered successfully"
                    if deleted
                    else "Device token not found"
                )
            }

        except Exception:
            self.db.rollback()
            raise
