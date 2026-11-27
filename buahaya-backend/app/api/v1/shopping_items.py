
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Response, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.schemas.user import UserResponse
from app.schemas.shopping_item import (
    ShoppingItemCreate,
    ShoppingItemUpdate,
    ShoppingItemResponse,
)
from app.services.shopping_item_service import ShoppingItemService


router = APIRouter(
    prefix="/shopping-items",
    tags=["Shopping Items"],
)


@router.get("", response_model=list[ShoppingItemResponse])
def get_shopping_items(
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    try:
        return ShoppingItemService(db).get_items(current_user.id)

    except LookupError as exc:
        raise HTTPException(status_code=404, detail=str(exc))

    except ValueError as exc:
        raise HTTPException(status_code=409, detail=str(exc))


@router.post(
    "",
    response_model=ShoppingItemResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_shopping_item(
    data: ShoppingItemCreate,
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    try:
        return ShoppingItemService(db).create_item(
            current_user.id,
            data,
        )

    except LookupError as exc:
        raise HTTPException(status_code=404, detail=str(exc))

    except ValueError as exc:
        raise HTTPException(status_code=409, detail=str(exc))


@router.patch(
    "/{item_id}",
    response_model=ShoppingItemResponse,
)
def update_shopping_item(
    item_id: UUID,
    data: ShoppingItemUpdate,
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    try:
        return ShoppingItemService(db).update_item(
            current_user.id,
            item_id,
            data,
        )

    except LookupError as exc:
        raise HTTPException(status_code=404, detail=str(exc))

    except ValueError as exc:
        raise HTTPException(status_code=409, detail=str(exc))


@router.delete(
    "/{item_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
def delete_shopping_item(
    item_id: UUID,
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    try:
        ShoppingItemService(db).delete_item(
            current_user.id,
            item_id,
        )
        return Response(status_code=status.HTTP_204_NO_CONTENT)

    except LookupError as exc:
        raise HTTPException(status_code=404, detail=str(exc))

    except ValueError as exc:
        raise HTTPException(status_code=409, detail=str(exc))
