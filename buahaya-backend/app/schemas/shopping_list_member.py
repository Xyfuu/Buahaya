
from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, EmailStr


class ShoppingListMemberResponse(BaseModel):
    user_id: UUID
    username: str
    email: EmailStr
    role: str
    joined_at: datetime

    model_config = ConfigDict(from_attributes=True)


class ShoppingListMembersResponse(BaseModel):
    shopping_list_id: UUID
    members: list[ShoppingListMemberResponse]
