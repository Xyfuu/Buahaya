
from fastapi import FastAPI, Depends
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.core.config import settings
from app.db.session import get_db
from app.api.v1.auth import router as auth_router
from app.api.v1.shopping_lists import router as shopping_lists_router


app = FastAPI(
    title=settings.APP_NAME,
    version="1.0.0",
)

app.include_router(
    auth_router,
    prefix=settings.API_V1_PREFIX,
)

app.include_router(
    shopping_lists_router,
    prefix=settings.API_V1_PREFIX,
)

@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "app": settings.APP_NAME,
    }


@app.get("/health/db")
def database_health_check(db: Session = Depends(get_db)):
    db.execute(text("SELECT 1"))

    return {
        "status": "healthy",
        "database": "connected",
    }
