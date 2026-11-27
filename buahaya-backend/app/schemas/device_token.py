
from typing import Literal
from pydantic import BaseModel, Field


class DeviceTokenRegister(BaseModel):
    token: str = Field(min_length=1, max_length=512)
    platform: Literal["android", "ios"] = "android"


class DeviceTokenResponse(BaseModel):
    message: str
