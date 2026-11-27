
from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class InvitationCreate(BaseModel):
    identifier: str = Field(min_length=1, max_length=255)


class InvitationResponse(BaseModel):
    id: UUID
    shopping_list_id: UUID
    inviter_id: UUID
    invitee_id: UUID
    status: str
    created_at: datetime
    responded_at: datetime | None

    model_config = ConfigDict(from_attributes=True)


class InvitationListResponse(BaseModel):
    invitations: list[InvitationResponse]
