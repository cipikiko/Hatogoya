from flask_sqlalchemy import SQLAlchemy
from datetime import datetime, timezone

db = SQLAlchemy()

class User(db.Model):
    __tablename__ = 'user'

    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.Text, nullable=False)
    email = db.Column(db.Text, unique=True, nullable=False)
    password_hash = db.Column(db.Text, nullable=False)
    role = db.Column(db.Text, default='visitor')
    created_at = db.Column(db.DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

    # ✅ EMAIL VERIFICATION
    email_verified = db.Column(db.Boolean, nullable=False, default=False)
    verification_token = db.Column(db.Text, nullable=True)
    verification_sent_at = db.Column(db.DateTime(timezone=True), nullable=True)

    # RESET PASSWORD
    reset_token = db.Column(db.Text, nullable=True)
    reset_sent_at = db.Column(db.DateTime(timezone=True), nullable=True)

