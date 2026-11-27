
from uuid import UUID

from sqlalchemy.orm import Session

from app.repositories.notification_repository import (
    NotificationRepository,
)
from app.schemas.notification import (
    NotificationResponse,
    NotificationListResponse,
)


class NotificationService:
    def __init__(self, db: Session):
        self.db = db
        self.repository = NotificationRepository(db)

    def get_my_notifications(self, user_id: UUID):
        notifications = self.repository.get_all_for_user(user_id)
        unread_count = self.repository.count_unread(user_id)

        return NotificationListResponse(
            notifications=[
                NotificationResponse.model_validate(item)
                for item in notifications
            ],
            unread_count=unread_count,
        )

    def mark_as_read(self, user_id: UUID, notification_id: UUID):
        try:
            notification = self.repository.get_for_user(
                notification_id,
                user_id,
            )

            if not notification:
                raise LookupError("Notification not found")

            if not notification.is_read:
                from datetime import datetime, timezone

                notification.is_read = True
                notification.read_at = datetime.now(timezone.utc)

            self.db.commit()
            self.db.refresh(notification)

            return NotificationResponse.model_validate(notification)

        except Exception:
            self.db.rollback()
            raise

    def mark_all_as_read(self, user_id: UUID):
        try:
            count = self.repository.mark_all_as_read(user_id)
            self.db.commit()

            return {"marked_as_read": count}

        except Exception:
            self.db.rollback()
            raise
