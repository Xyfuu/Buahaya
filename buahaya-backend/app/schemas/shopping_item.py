
from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, field_validator
from typing import Literal

class ShoppingItemCreate(BaseModel):
    fruit_type: Literal["Apple", "Banana", "Orange", "Tomato", "Mango"]
    target_quantity: int = Field(gt=0)
    unit: str = Field(default="pcs", min_length=1, max_length=20)

    @field_validator("fruit_type", "unit")
    @classmethod
    def validate_text(cls, value: str) -> str:
        value = value.strip()
        if not value:
            raise ValueError("Value cannot be empty")
        return value


class ShoppingItemUpdate(BaseModel):
    fruit_type: Literal["Apple", "Banana", "Orange", "Tomato", "Mango"] | None = None
    target_quantity: int | None = Field(default=None, gt=0)
    unit: str | None = Field(default=None, min_length=1, max_length=20)

    @field_validator("fruit_type", "unit")
    @classmethod
    def validate_text(cls, value: str | None) -> str | None:
        if value is None:
            return value

        value = value.strip()
        if not value:
            raise ValueError("Value cannot be empty")
        return value


class ShoppingItemResponse(BaseModel):
    id: UUID
    shopping_list_id: UUID
    fruit_type: str
    target_quantity: int
    remaining_quantity: int
    unit: str
    is_purchased: bool
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
