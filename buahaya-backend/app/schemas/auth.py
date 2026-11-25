from pydantic import BaseModel, Field
from app.schemas.user import UserCreate, UserResponse

class RegisterRequest(UserCreate):
    pass

class LoginRequest(BaseModel):
    identifier: str = Field(min_length=1, max_length=255)
    password: str = Field(min_length=1, max_length=128)

class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int

class RefreshTokenRequest(BaseModel):
    refresh_token: str

class AuthResponse(BaseModel):
    user: UserResponse
    tokens: TokenResponse