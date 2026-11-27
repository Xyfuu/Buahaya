
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.schemas.user import UserResponse
from app.schemas.device_token import (
    DeviceTokenRegister,
    DeviceTokenResponse,
)
from app.services.device_token_service import DeviceTokenService


router = APIRouter(
    prefix="/devices",
    tags=["Device Tokens"],
)


@router.post(
    "/register",
    response_model=DeviceTokenResponse,
)
def register_device_token(
    data: DeviceTokenRegister,
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return DeviceTokenService(db).register_token(
        user_id=current_user.id,
        token=data.token,
        platform=data.platform,
    )


@router.delete(
    "/unregister",
    response_model=DeviceTokenResponse,
)
def unregister_device_token(
    data: DeviceTokenRegister,
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return DeviceTokenService(db).unregister_token(
        user_id=current_user.id,
        token=data.token,
    )
