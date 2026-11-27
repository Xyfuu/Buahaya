
from uuid import UUID
from datetime import datetime, timezone
from sqlalchemy.orm import Session

from app.repositories.shopping_list_invitation_repository import (
    ShoppingListInvitationRepository,
)
from app.schemas.shopping_list_invitation import (
    InvitationCreate,
    InvitationResponse,
    InvitationListResponse,
)
from app.repositories.notification_repository import NotificationRepository

import logging

from app.services.push_notification_service import (
    PushNotificationService,
)

logger = logging.getLogger(__name__)

class ShoppingListInvitationService:
    def __init__(self, db: Session):
        self.db = db
        self.repository = ShoppingListInvitationRepository(db)
        self.notification_repository = NotificationRepository(db)

    def create_invitation(
        self,
        user_id: UUID,
        data: InvitationCreate,
    ):
        try:
            membership = self.repository.get_membership(user_id)

            if not membership:
                raise LookupError(
                    "You do not belong to an active shopping list"
                )

            shopping_list = self.repository.get_list(
                membership.shopping_list_id
            )

            if not shopping_list or shopping_list.status != "active":
                raise ValueError("Shopping list is not active")

            if (
                membership.role != "owner"
                or shopping_list.owner_id != user_id
            ):
                raise PermissionError(
                    "Only the shopping list owner can invite members"
                )

            identifier = data.identifier.strip()

            if "@" in identifier:
                identifier = identifier.lower()

            invitee = self.repository.get_user_by_identifier(identifier)

            if not invitee or not invitee.is_active:
                raise LookupError("Invited user not found")

            if invitee.id == user_id:
                raise ValueError("You cannot invite yourself")

            existing_membership = self.repository.get_membership(
                invitee.id
            )

            if (
                existing_membership
                and existing_membership.shopping_list_id
                == shopping_list.id
            ):
                raise ValueError(
                    "User is already a member of this shopping list"
                )

            pending = self.repository.get_pending_invitation(
                shopping_list.id,
                invitee.id,
            )

            if pending:
                raise ValueError(
                    "A pending invitation already exists for this user"
                )

            invitation = self.repository.create_invitation(
                shopping_list_id=shopping_list.id,
                inviter_id=user_id,
                invitee_id=invitee.id,
            )

            self.notification_repository.create(
                user_id=invitee.id,
                actor_id=user_id,
                notification_type="shopping_list_invitation",
                title="Undangan Shopping List Baru",
                message=f"Kamu diundang ke shopping list {shopping_list.name}.",
                data={
                    "invitation_id": str(invitation.id),
                    "shopping_list_id": str(shopping_list.id),
                    "inviter_id": str(user_id),
                },
            )

            self.db.commit()
            self.db.refresh(invitation)

            try:
                PushNotificationService(self.db).send_to_user(
                    user_id=invitee.id,
                    title="Undangan Shopping List Baru",
                    body=f"Kamu diundang ke shopping list {shopping_list.name}.",
                    data={
                        "type": "shopping_list_invitation",
                        "invitation_id": str(invitation.id),
                        "shopping_list_id": str(shopping_list.id),
                    },
                )
            except Exception:
                logger.exception("Failed to send invitation push notification")

            return InvitationResponse.model_validate(invitation)

        except Exception:
            self.db.rollback()
            raise

    def get_my_invitations(self, user_id: UUID):
        invitations = self.repository.get_incoming_pending(user_id)

        return InvitationListResponse(
            invitations=[
                InvitationResponse.model_validate(invitation)
                for invitation in invitations
            ]
        )

    def accept_invitation(
        self,
        user_id: UUID,
        invitation_id: UUID,
    ):
        try:
            invitation = self.repository.get_invitation_for_update(
                invitation_id
            )

            if not invitation or invitation.invitee_id != user_id:
                raise LookupError("Invitation not found")

            if invitation.status != "pending":
                raise ValueError("Invitation is no longer pending")

            target_list = self.repository.get_list(
                invitation.shopping_list_id,
                lock=True,
            )

            if not target_list or target_list.status != "active":
                raise ValueError("Target shopping list is not active")

            inviter_membership = self.repository.get_membership(
                invitation.inviter_id
            )

            if (
                target_list.owner_id != invitation.inviter_id
                or not inviter_membership
                or inviter_membership.shopping_list_id != target_list.id
                or inviter_membership.role != "owner"
            ):
                raise ValueError(
                    "Invitation is no longer valid because ownership changed"
                )

            current_membership = self.repository.get_membership(
                user_id,
                lock=True,
            )

            if current_membership:
                if current_membership.shopping_list_id == target_list.id:
                    raise ValueError(
                        "You are already a member of this shopping list"
                    )

                old_list = self.repository.get_list(
                    current_membership.shopping_list_id,
                    lock=True,
                )

                if (
                    current_membership.role == "owner"
                    and old_list
                    and old_list.owner_id == user_id
                ):
                    other_members = [
                        member
                        for member in self.repository.get_active_members(
                            old_list.id
                        )
                        if member.user_id != user_id
                    ]

                    if other_members:
                        raise ValueError(
                            "Transfer ownership of your current shopping list "
                            "before joining another list"
                        )

                current_membership.left_at = datetime.now(timezone.utc)
                self.db.flush()

            self.repository.create_membership(
                shopping_list_id=target_list.id,
                user_id=user_id,
            )

            self.repository.respond_to_invitation(
                invitation,
                "accepted",
            )

            self.db.commit()
            self.db.refresh(invitation)

            return InvitationResponse.model_validate(invitation)

        except Exception:
            self.db.rollback()
            raise

    def reject_invitation(
        self,
        user_id: UUID,
        invitation_id: UUID,
    ):
        try:
            invitation = self.repository.get_invitation_for_update(
                invitation_id
            )

            if not invitation or invitation.invitee_id != user_id:
                raise LookupError("Invitation not found")

            if invitation.status != "pending":
                raise ValueError("Invitation is no longer pending")

            self.repository.respond_to_invitation(
                invitation,
                "rejected",
            )

            self.db.commit()
            self.db.refresh(invitation)

            return InvitationResponse.model_validate(invitation)

        except Exception:
            self.db.rollback()
            raise
