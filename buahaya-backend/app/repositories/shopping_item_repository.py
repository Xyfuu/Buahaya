
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.shopping_item import ShoppingItem
from app.models.shopping_list import ShoppingList
from app.models.shopping_list_member import ShoppingListMember


class ShoppingItemRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_active_membership(self, user_id: UUID):
        return self.db.scalar(
            select(ShoppingListMember).where(
                ShoppingListMember.user_id == user_id,
                ShoppingListMember.left_at.is_(None),
            )
        )

    def get_shopping_list(self, shopping_list_id: UUID):
        return self.db.get(ShoppingList, shopping_list_id)

    def get_by_id(self, item_id: UUID, shopping_list_id: UUID):
        return self.db.scalar(
            select(ShoppingItem).where(
                ShoppingItem.id == item_id,
                ShoppingItem.shopping_list_id == shopping_list_id,
            )
        )

    def get_all(self, shopping_list_id: UUID):
        return list(
            self.db.scalars(
                select(ShoppingItem)
                .where(ShoppingItem.shopping_list_id == shopping_list_id)
                .order_by(ShoppingItem.created_at)
            ).all()
        )

    def create(
        self,
        shopping_list_id: UUID,
        fruit_type: str,
        target_quantity: int,
        unit: str,
    ):
        item = ShoppingItem(
            shopping_list_id=shopping_list_id,
            fruit_type=fruit_type,
            target_quantity=target_quantity,
            remaining_quantity=target_quantity,
            unit=unit,
            is_purchased=False,
        )
        self.db.add(item)
        self.db.flush()
        return item

    def update(self, item: ShoppingItem):
        self.db.flush()
        return item

    def delete(self, item: ShoppingItem):
        self.db.delete(item)
        self.db.flush()
