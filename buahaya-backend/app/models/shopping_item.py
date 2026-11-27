
import uuid

from sqlalchemy import (
    Boolean,
    CheckConstraint,
    DateTime,
    ForeignKey,
    Integer,
    String,
    Uuid,
    func,
)
from sqlalchemy.orm import Mapped, mapped_column

from app.db.session import Base


class ShoppingItem(Base):
    __tablename__ = "shopping_items"

    __table_args__ = (
        CheckConstraint(
            "target_quantity > 0",
            name="ck_shopping_items_target_quantity",
        ),
        CheckConstraint(
            "remaining_quantity >= 0",
            name="ck_shopping_items_remaining_quantity",
        ),
        CheckConstraint(
            "remaining_quantity <= target_quantity",
            name="ck_shopping_items_remaining_not_exceed_target",
        ),
        CheckConstraint(
            "fruit_type IN ('Apple', 'Banana', 'Orange', 'Mango', 'Tomato')",
            name="ck_shopping_items_fruit_type",
        ),
    )

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
    )

    shopping_list_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True),
        ForeignKey("shopping_lists.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    fruit_type: Mapped[str] = mapped_column(
        String(50),
        nullable=False,
    )

    target_quantity: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
    )

    remaining_quantity: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
    )

    unit: Mapped[str] = mapped_column(
        String(20),
        default="pcs",
        nullable=False,
    )

    is_purchased: Mapped[bool] = mapped_column(
        Boolean,
        default=False,
        nullable=False,
    )

    created_at: Mapped[DateTime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )

    updated_at: Mapped[DateTime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False,
    )
