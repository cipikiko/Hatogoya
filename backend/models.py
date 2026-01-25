from __future__ import annotations

from datetime import datetime, timezone

from flask_sqlalchemy import SQLAlchemy


db = SQLAlchemy()


class User(db.Model):
    __tablename__ = 'user'

    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.Text, nullable=False)
    email = db.Column(db.Text, unique=True, nullable=False)
    password_hash = db.Column(db.Text, nullable=False)
    role = db.Column(db.Text, default='visitor')
    created_at = db.Column(db.DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

    # Email verification
    email_verified = db.Column(db.Boolean, nullable=False, default=False)
    verification_token = db.Column(db.Text, nullable=True)
    verification_sent_at = db.Column(db.DateTime(timezone=True), nullable=True)

    # Password reset
    reset_token = db.Column(db.Text, nullable=True)
    reset_sent_at = db.Column(db.DateTime(timezone=True), nullable=True)


class Plant(db.Model):
    __tablename__ = 'plants'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.Text, nullable=False)
    description = db.Column(db.Text, nullable=True)
    qr_token = db.Column(db.Text, nullable=False, unique=True)
    asset_path = db.Column(db.Text, nullable=True)


class UserPlant(db.Model):
    __tablename__ = 'user_plants'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id', ondelete='CASCADE'), nullable=False)
    plant_id = db.Column(db.Integer, db.ForeignKey('plants.id', ondelete='CASCADE'), nullable=False)
    scanned_at = db.Column(db.DateTime(timezone=True), server_default=db.func.now())

    __table_args__ = (
        db.UniqueConstraint('user_id', 'plant_id', name='user_plants_unique'),
    )
