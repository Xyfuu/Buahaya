
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.schemas.user import UserResponse
from app.schemas.shopping_list import (
    ShoppingListCreate,
    ShoppingListResponse,
    ShoppingListUpdate
)
from app.schemas.shopping_list_member import ShoppingListMembersResponse
from app.services.shopping_list_service import ShoppingListService
from app.schemas.shopping_list_ownership import TransferOwnershipRequest

router = APIRouter(
    prefix="/shopping-lists",
    tags=["Shopping Lists"],
)


@router.post(
    "",
    response_model=ShoppingListResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_shopping_list(
    data: ShoppingListCreate,
    db: Session = Depends(get_db),
    current_user: UserResponse = Depends(get_current_user),
):
    try:
        return ShoppingListService(db).create_list(
            user_id=current_user.id,
            data=data,
        )
    except ValueError as error:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=str(error),
        )
    except IntegrityError:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="You already belong to an active shopping list",
        )


@router.get(
    "/me",
    response_model=ShoppingListResponse,
)
def get_my_shopping_list(
    db: Session = Depends(get_db),
    current_user: UserResponse = Depends(get_current_user),
):
    service = ShoppingListService(db)

    try:
        return service.get_my_list(current_user.id)
    except ValueError as error:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(error),
        )


@router.patch(
    "/me",
    response_model=ShoppingListResponse,
)
def update_my_shopping_list(
    data: ShoppingListUpdate,
    db: Session = Depends(get_db),
    current_user: UserResponse = Depends(get_current_user),
):
    service = ShoppingListService(db)

    try:
        return service.update_my_list(
            user_id=current_user.id,
            data=data,
        )
    except PermissionError as error:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=str(error),
        )
    except ValueError as error:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(error),
        )


@router.get(
    "/me/members",
    response_model=ShoppingListMembersResponse,
)
def get_my_shopping_list_members(
    db: Session = Depends(get_db),
    current_user: UserResponse = Depends(get_current_user),
):
    service = ShoppingListService(db)

    try:
        return service.get_my_members(current_user.id)
    except ValueError as error:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(error),
        )


@router.post(
    "/me/transfer-ownership",
    response_model=ShoppingListResponse,
)
def transfer_shopping_list_ownership(
    data: TransferOwnershipRequest,
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    try:
        return ShoppingListService(db).transfer_ownership(
            current_user.id,
            data.new_owner_id,
        )

    except PermissionError as exc:
        raise HTTPException(status_code=403, detail=str(exc))

    except LookupError as exc:
        raise HTTPException(status_code=404, detail=str(exc))

    except ValueError as exc:
        raise HTTPException(status_code=409, detail=str(exc))
