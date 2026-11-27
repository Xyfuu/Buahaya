
from uuid import UUID

from sqlalchemy.orm import Session

from app.repositories.shopping_list_repository import (
    ShoppingListRepository,
)
from app.schemas.shopping_list import (
    ShoppingListCreate,
    ShoppingListResponse,
    ShoppingListUpdate
)

from app.schemas.shopping_list_member import (
    ShoppingListMemberResponse,
    ShoppingListMembersResponse,
)


class ShoppingListService:
    def __init__(self, db: Session):
        self.db = db
        self.repository = ShoppingListRepository(db)

    def create_list(
        self,
        user_id: UUID,
        data: ShoppingListCreate,
    ) -> ShoppingListResponse:
        try:
            existing_membership = (
                self.repository.get_active_membership(user_id)
            )

            if existing_membership:
                raise ValueError(
                    "You already belong to an active shopping list"
                )

            name=data.name.strip()

            if not name:
                raise ValueError("Shopping List Name Cannot Be Empty")

            shopping_list = self.repository.create_list(
                name=name,
                owner_id=user_id,
            )

            self.db.commit()
            self.db.refresh(shopping_list)

            return ShoppingListResponse.model_validate(
                shopping_list
            )

        except Exception:
            self.db.rollback()
            raise

    def get_my_list(self, user_id: UUID) -> ShoppingListResponse:
        membership = self.repository.get_active_membership(user_id)

        if not membership:
            raise ValueError("You do not belong to an active shopping list")

        shopping_list = self.repository.get_list_by_id(
            membership.shopping_list_id
        )

        if not shopping_list:
            raise ValueError("Shopping list not found")

        return ShoppingListResponse.model_validate(shopping_list)


    
    def update_my_list(
        self,
        user_id: UUID,
        data: ShoppingListUpdate,
    ) -> ShoppingListResponse:
        try:
            membership = self.repository.get_active_membership(user_id)

            if not membership:
                raise ValueError(
                    "You do not belong to an active shopping list"
                )

            if membership.role != "owner":
                raise PermissionError(
                    "Only the shopping list owner can update its name"
                )

            shopping_list = self.repository.get_list_by_id(
                membership.shopping_list_id
            )

            if not shopping_list:
                raise ValueError("Shopping list not found")

            if shopping_list.owner_id != user_id:
                raise PermissionError(
                    "Only the shopping list owner can update its name"
                )

            updated_list = self.repository.update_list_name(
                shopping_list=shopping_list,
                name=data.name,
            )

            self.db.commit()
            self.db.refresh(updated_list)

            return ShoppingListResponse.model_validate(updated_list)

        except Exception:
            self.db.rollback()
            raise

    
    def get_my_members(
        self,
        user_id: UUID,
    ) -> ShoppingListMembersResponse:
        membership = self.repository.get_active_membership(user_id)

        if not membership:
            raise ValueError(
                "You do not belong to an active shopping list"
            )

        members_data = self.repository.get_active_members(
            membership.shopping_list_id
        )

        members = [
            ShoppingListMemberResponse(
                user_id=member.user_id,
                username=user.username,
                email=user.email,
                role=member.role,
                joined_at=member.joined_at,
            )
            for member, user in members_data
        ]

        return ShoppingListMembersResponse(
            shopping_list_id=membership.shopping_list_id,
            members=members,
        )


    def transfer_ownership(self, user_id, new_owner_id):
        try:
            membership = self.repository.get_active_membership(user_id)

            if not membership:
                raise LookupError(
                    "You do not belong to an active shopping list"
                )

            shopping_list = self.repository.get_list_by_id(
                membership.shopping_list_id
            )

            if not shopping_list or shopping_list.status != "active":
                raise ValueError("Shopping list is not active")

            if (
                membership.role != "owner"
                or shopping_list.owner_id != user_id
            ):
                raise PermissionError(
                    "Only the current owner can transfer ownership"
                )

            if new_owner_id == user_id:
                raise ValueError("You are already the owner")

            members = self.repository.get_active_members_for_update(
                shopping_list.id
            )

            new_owner_membership = next(
                (
                    member
                    for member in members
                    if member.user_id == new_owner_id
                ),
                None,
            )

            if not new_owner_membership:
                raise LookupError(
                    "New owner must be an active member of this shopping list"
                )

            old_owner_membership = next(
                (
                    member
                    for member in members
                    if member.user_id == user_id
                ),
                None,
            )

            if not old_owner_membership:
                raise LookupError("Current owner membership not found")

            old_owner_membership.role = "member"
            new_owner_membership.role = "owner"
            shopping_list.owner_id = new_owner_id

            self.db.commit()
            self.db.refresh(shopping_list)

            return ShoppingListResponse.model_validate(shopping_list)

        except Exception:
            self.db.rollback()
            raise
