
from uuid import UUID

from sqlalchemy.orm import Session

from app.repositories.shopping_item_repository import ShoppingItemRepository
from app.schemas.shopping_item import (
    ShoppingItemCreate,
    ShoppingItemUpdate,
    ShoppingItemResponse,
)


class ShoppingItemService:
    def __init__(self, db: Session):
        self.db = db
        self.repository = ShoppingItemRepository(db)

    def _get_active_shopping_list(self, user_id: UUID):
        membership = self.repository.get_active_membership(user_id)

        if not membership:
            raise LookupError("You do not belong to an active shopping list")

        shopping_list = self.repository.get_shopping_list(
            membership.shopping_list_id
        )

        if not shopping_list:
            raise LookupError("Shopping list not found")

        if shopping_list.status != "active":
            raise ValueError("Shopping list is not active")

        return shopping_list

    def get_items(self, user_id: UUID):
        shopping_list = self._get_active_shopping_list(user_id)

        items = self.repository.get_all(shopping_list.id)

        return [
            ShoppingItemResponse.model_validate(item)
            for item in items
        ]

    def create_item(self, user_id: UUID, data: ShoppingItemCreate):
        shopping_list = self._get_active_shopping_list(user_id)

        try:
            item = self.repository.create(
                shopping_list_id=shopping_list.id,
                fruit_type=data.fruit_type,
                target_quantity=data.target_quantity,
                unit=data.unit,
            )

            self.db.commit()
            self.db.refresh(item)

            return ShoppingItemResponse.model_validate(item)

        except Exception:
            self.db.rollback()
            raise

    def update_item(
        self,
        user_id: UUID,
        item_id: UUID,
        data: ShoppingItemUpdate,
    ):
        shopping_list = self._get_active_shopping_list(user_id)

        item = self.repository.get_by_id(item_id, shopping_list.id)

        if not item:
            raise LookupError("Shopping item not found")

        try:
            update_data = data.model_dump(exclude_unset=True)

            if "fruit_type" in update_data:
                item.fruit_type = update_data["fruit_type"]

            if "unit" in update_data:
                item.unit = update_data["unit"]

            if "target_quantity" in update_data:
                new_target = update_data["target_quantity"]
                old_target = item.target_quantity

                quantity_difference = new_target - old_target

                new_remaining = item.remaining_quantity + quantity_difference

                item.target_quantity = new_target
                item.remaining_quantity = max(
                    0,
                    min(new_remaining, new_target),
                )

                item.is_purchased = item.remaining_quantity == 0

            self.repository.update(item)

            self.db.commit()
            self.db.refresh(item)

            return ShoppingItemResponse.model_validate(item)

        except Exception:
            self.db.rollback()
            raise

    def delete_item(self, user_id: UUID, item_id: UUID):
        shopping_list = self._get_active_shopping_list(user_id)

        item = self.repository.get_by_id(item_id, shopping_list.id)

        if not item:
            raise LookupError("Shopping item not found")

        try:
            self.repository.delete(item)
            self.db.commit()

        except Exception:
            self.db.rollback()
            raise
