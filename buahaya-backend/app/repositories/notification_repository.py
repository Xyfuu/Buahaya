
from datetime import datetime, timezone
from uuid import UUID

from sqlalchemy import select, func
from sqlalchemy.orm import Session

from app.models.notification import Notification


class NotificationRepository:
    def __init__(self, db: Session):
        self.db = db

    def create(
        self,
        user_id: UUID,
        notification_type: str,
        title: str,
        message: str,
        data: dict,
        actor_id: UUID | None = None,
    ):
        notification = Notification(
            user_id=user_id,
            actor_id=actor_id,
            notification_type=notification_type,
            title=title,
            message=message,
            data=data,
        )

        self.db.add(notification)
        self.db.flush()

        return notification

    def get_for_user(self, notification_id: UUID, user_id: UUID):
        return self.db.scalar(
            select(Notification)
            .where(
                Notification.id == notification_id,
                Notification.user_id == user_id,
            )
            .with_for_update()
        )

    def get_all_for_user(self, user_id: UUID):
        return list(
            self.db.scalars(
                select(Notification)
                .where(Notification.user_id == user_id)
                .order_by(Notification.created_at.desc())
            ).all()
        )

    def count_unread(self, user_id: UUID):
        return self.db.scalar(
            select(func.count())
            .select_from(Notification)
            .where(
                Notification.user_id == user_id,
                Notification.is_read.is_(False),
            )
        ) or 0

    def mark_all_as_read(self, user_id: UUID):
        notifications = self.db.scalars(
            select(Notification)
            .where(
                Notification.user_id == user_id,
                Notification.is_read.is_(False),
            )
            .with_for_update()
        ).all()

        now = datetime.now(timezone.utc)

        for notification in notifications:
            notification.is_read = True
            notification.read_at = now

        self.db.flush()

        return len(notifications)
