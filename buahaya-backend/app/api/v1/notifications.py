
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.schemas.user import UserResponse
from app.schemas.notification import (
    NotificationResponse,
    NotificationListResponse,
)
from app.services.notification_service import NotificationService


router = APIRouter(
    prefix="/notifications",
    tags=["Notifications"],
)


@router.get(
    "/me",
    response_model=NotificationListResponse,
)
def get_my_notifications(
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return NotificationService(db).get_my_notifications(
        current_user.id
    )


@router.patch(
    "/{notification_id}/read",
    response_model=NotificationResponse,
)
def mark_notification_as_read(
    notification_id: UUID,
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    try:
        return NotificationService(db).mark_as_read(
            current_user.id,
            notification_id,
        )

    except LookupError as exc:
        raise HTTPException(status_code=404, detail=str(exc))


@router.post("/read-all")
def mark_all_notifications_as_read(
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return NotificationService(db).mark_all_as_read(
        current_user.id
    )
