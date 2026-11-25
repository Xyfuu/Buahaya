from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, field_validator

class ShoppingListCreate(BaseModel):
    name: str = Field(min_length=1, max_length=100)

class ShoppingListUpdate(BaseModel):
    name: str = Field(min_length=1, max_length=100)

class ShoppingListResponse(BaseModel):
    id: UUID
    name: str
    owner_id: UUID
    status: str
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)

class ShoppingListUpdate(BaseModel):
    name: str = Field(min_length=1, max_length=100)

    @field_validator("name")
    @classmethod
    def validate_name(cls, value: str) -> str:
        value = value.strip()

        if not value:
            raise ValueError("Shopping list name cannot be empty")

        return value
