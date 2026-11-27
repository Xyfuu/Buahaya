
from datetime import datetime, timezone
from uuid import UUID

from sqlalchemy import or_, select
from sqlalchemy.orm import Session

from app.models.user import User
from app.models.shopping_list import ShoppingList
from app.models.shopping_list_member import ShoppingListMember
from app.models.shopping_list_invitation import ShoppingListInvitation


class ShoppingListInvitationRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_user_by_identifier(self, identifier: str):
        return self.db.scalar(
            select(User).where(
                or_(
                    User.email == identifier,
                    User.username == identifier,
                )
            )
        )

    def get_membership(self, user_id: UUID, lock: bool = False):
        statement = select(ShoppingListMember).where(
            ShoppingListMember.user_id == user_id,
            ShoppingListMember.left_at.is_(None),
        )

        if lock:
            statement = statement.with_for_update()

        return self.db.scalar(statement)

    def get_list(self, shopping_list_id: UUID, lock: bool = False):
        statement = select(ShoppingList).where(
            ShoppingList.id == shopping_list_id
        )

        if lock:
            statement = statement.with_for_update()

        return self.db.scalar(statement)

    def get_active_members(self, shopping_list_id: UUID):
        return list(
            self.db.scalars(
                select(ShoppingListMember).where(
                    ShoppingListMember.shopping_list_id == shopping_list_id,
                    ShoppingListMember.left_at.is_(None),
                )
            ).all()
        )

    def get_pending_invitation(
        self,
        shopping_list_id: UUID,
        invitee_id: UUID,
    ):
        return self.db.scalar(
            select(ShoppingListInvitation).where(
                ShoppingListInvitation.shopping_list_id == shopping_list_id,
                ShoppingListInvitation.invitee_id == invitee_id,
                ShoppingListInvitation.status == "pending",
            )
        )

    def create_invitation(
        self,
        shopping_list_id: UUID,
        inviter_id: UUID,
        invitee_id: UUID,
    ):
        invitation = ShoppingListInvitation(
            shopping_list_id=shopping_list_id,
            inviter_id=inviter_id,
            invitee_id=invitee_id,
            status="pending",
        )

        self.db.add(invitation)
        self.db.flush()

        return invitation

    def get_incoming_pending(self, invitee_id: UUID):
        return list(
            self.db.scalars(
                select(ShoppingListInvitation)
                .where(
                    ShoppingListInvitation.invitee_id == invitee_id,
                    ShoppingListInvitation.status == "pending",
                )
                .order_by(ShoppingListInvitation.created_at.desc())
            ).all()
        )

    def get_invitation_for_update(self, invitation_id: UUID):
        return self.db.scalar(
            select(ShoppingListInvitation)
            .where(ShoppingListInvitation.id == invitation_id)
            .with_for_update()
        )

    def create_membership(
        self,
        shopping_list_id: UUID,
        user_id: UUID,
    ):
        membership = ShoppingListMember(
            shopping_list_id=shopping_list_id,
            user_id=user_id,
            role="member",
        )

        self.db.add(membership)
        self.db.flush()

        return membership

    def respond_to_invitation(
        self,
        invitation: ShoppingListInvitation,
        status: str,
    ):
        invitation.status = status
        invitation.responded_at = datetime.now(timezone.utc)
        self.db.flush()

        return invitation
