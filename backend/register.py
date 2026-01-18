from flask import Blueprint, request, jsonify
from werkzeug.security import generate_password_hash
from datetime import datetime, timezone
import secrets

from models import db, User
from email_utils import send_verification_email
from cleanup import cleanup_unverified_users

register_bp = Blueprint("register", __name__)

@register_bp.route("/register", methods=["POST"])
def register():
    # 🧼 zmaž staré neoverené účty (safe volať vždy)
    cleanup_unverified_users()

    data = request.json or {}
    username = data.get("username")
    email = data.get("email")
    password = data.get("password")
    role = data.get("role", "visitor")

    if not username or not email or not password:
        return jsonify({"message": "Username, email, and password are required"}), 400

    if User.query.filter_by(email=email).first():
        return jsonify({"message": "Email already exists"}), 400

    hashed_password = generate_password_hash(password, method="pbkdf2:sha256")
    token = secrets.token_urlsafe(32)

    new_user = User(
        username=username,
        email=email,
        password_hash=hashed_password,
        role=role,
        email_verified=False,
        verification_token=token,
        verification_sent_at=datetime.now(timezone.utc),
    )

    db.session.add(new_user)
    db.session.commit()

    try:
        send_verification_email(email, token)
    except Exception as e:
        return jsonify({
            "message": "User registered, but verification email failed to send",
            "error": str(e)
        }), 500

    return jsonify({"message": "User registered. Verification email sent."}), 201