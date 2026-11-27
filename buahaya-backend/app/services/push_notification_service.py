
import logging

import firebase_admin
from firebase_admin import credentials, messaging
from firebase_admin.exceptions import FirebaseError
from sqlalchemy.orm import Session

from app.core.config import settings
from app.repositories.device_token_repository import (
    DeviceTokenRepository,
)


logger = logging.getLogger(__name__)


def get_firebase_app():
    if not settings.FIREBASE_CREDENTIALS_PATH:
        raise RuntimeError(
            "Firebase credentials path is not configured"
        )

    try:
        return firebase_admin.get_app("buahaya")

    except ValueError:
        credential = credentials.Certificate(
            settings.FIREBASE_CREDENTIALS_PATH
        )

        return firebase_admin.initialize_app(
            credential,
            name="buahaya",
        )


class PushNotificationService:
    def __init__(self, db: Session):
        self.db = db
        self.repository = DeviceTokenRepository(db)

    def send_to_user(
        self,
        user_id,
        title: str,
        body: str,
        data: dict,
    ):
        if not settings.FIREBASE_CREDENTIALS_PATH:
            logger.warning(
                "FCM skipped: Firebase credentials are not configured"
            )
            return

        try:
            firebase_app = get_firebase_app()
        except Exception:
            logger.exception("Unable to initialize Firebase")
            return

        devices = self.repository.get_tokens_by_user(user_id)

        for device in devices:
            message = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=body,
                ),
                data={
                    str(key): str(value)
                    for key, value in data.items()
                },
                token=device.token,
            )

            try:
                messaging.send(message, app=firebase_app)

            except messaging.UnregisteredError:
                logger.warning(
                    "Removing expired FCM token for user %s",
                    user_id,
                )

                self.repository.delete_token(
                    user_id,
                    device.token,
                )

            except messaging.SenderIdMismatchError:
                logger.warning(
                    "Removing FCM token with sender mismatch"
                )

                self.repository.delete_token(
                    user_id,
                    device.token,
                )

            except FirebaseError:
                logger.exception(
                    "FCM delivery failed for user %s",
                    user_id,
                )

        try:
            self.db.commit()
        except Exception:
            self.db.rollback()
            logger.exception("Failed to clean up invalid FCM tokens")
