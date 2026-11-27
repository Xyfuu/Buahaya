
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.user import User
from app.models.shopping_list import ShoppingList
from app.models.shopping_list_member import ShoppingListMember


class ShoppingListRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_active_membership(
        self,
        user_id: UUID,
    ) -> ShoppingListMember | None:
        statement = (
            select(ShoppingListMember)
            .where(
                ShoppingListMember.user_id == user_id,
                ShoppingListMember.left_at.is_(None),
            )
        )
        return self.db.scalar(statement)

    def get_list_by_id(
        self,
        shopping_list_id: UUID,
    ) -> ShoppingList | None:
        return self.db.get(ShoppingList, shopping_list_id)

    def create_list(
        self,
        name: str,
        owner_id: UUID,
    ) -> ShoppingList:
        shopping_list = ShoppingList(
            name=name,
            owner_id=owner_id,
        )

        self.db.add(shopping_list)
        self.db.flush()

        membership = ShoppingListMember(
            shopping_list_id=shopping_list.id,
            user_id=owner_id,
            role="owner",
        )

        self.db.add(membership)
        self.db.flush()

        return shopping_list

    
    def update_list_name(
        self,
        shopping_list: ShoppingList,
        name: str,
    ) -> ShoppingList:
        shopping_list.name = name
        self.db.flush()
        return shopping_list

    
    def get_active_members(self, shopping_list_id: UUID):
        statement = (
            select(ShoppingListMember, User)
            .join(User, ShoppingListMember.user_id == User.id)
            .where(
                ShoppingListMember.shopping_list_id == shopping_list_id,
                ShoppingListMember.left_at.is_(None),
            )
            .order_by(ShoppingListMember.joined_at.asc())
        )

        return self.db.execute(statement).all()


    def get_active_members_for_update(self, shopping_list_id):
        from sqlalchemy import select

        return list(
            self.db.scalars(
                select(ShoppingListMember)
                .where(
                    ShoppingListMember.shopping_list_id == shopping_list_id,
                    ShoppingListMember.left_at.is_(None),
                )
                .with_for_update()
            ).all()
        )

