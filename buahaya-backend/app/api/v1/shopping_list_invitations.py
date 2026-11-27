
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.schemas.user import UserResponse
from app.schemas.shopping_list_invitation import (
    InvitationCreate,
    InvitationResponse,
    InvitationListResponse,
)
from app.services.shopping_list_invitation_service import (
    ShoppingListInvitationService,
)


router = APIRouter(tags=["Shopping List Invitations"])


@router.post(
    "/shopping-lists/me/invitations",
    response_model=InvitationResponse,
    status_code=201,
)
def create_invitation(
    data: InvitationCreate,
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    try:
        return ShoppingListInvitationService(db).create_invitation(
            current_user.id,
            data,
        )

    except PermissionError as exc:
        raise HTTPException(status_code=403, detail=str(exc))

    except LookupError as exc:
        raise HTTPException(status_code=404, detail=str(exc))

    except ValueError as exc:
        raise HTTPException(status_code=409, detail=str(exc))

    except IntegrityError:
        raise HTTPException(
            status_code=409,
            detail="Invitation already exists or conflicts with current data",
        )


@router.get(
    "/invitations/me",
    response_model=InvitationListResponse,
)
def get_my_invitations(
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return ShoppingListInvitationService(db).get_my_invitations(
        current_user.id
    )


@router.post(
    "/invitations/{invitation_id}/accept",
    response_model=InvitationResponse,
)
def accept_invitation(
    invitation_id: UUID,
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    try:
        return ShoppingListInvitationService(db).accept_invitation(
            current_user.id,
            invitation_id,
        )

    except LookupError as exc:
        raise HTTPException(status_code=404, detail=str(exc))

    except ValueError as exc:
        raise HTTPException(status_code=409, detail=str(exc))

    except IntegrityError:
        raise HTTPException(
            status_code=409,
            detail="Membership conflict. Please try again.",
        )


@router.post(
    "/invitations/{invitation_id}/reject",
    response_model=InvitationResponse,
)
def reject_invitation(
    invitation_id: UUID,
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    try:
        return ShoppingListInvitationService(db).reject_invitation(
            current_user.id,
            invitation_id,
        )

    except LookupError as exc:
        raise HTTPException(status_code=404, detail=str(exc))

    except ValueError as exc:
        raise HTTPException(status_code=409, detail=str(exc))
