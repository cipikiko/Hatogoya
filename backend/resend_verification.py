from flask import Blueprint, request, jsonify
from datetime import datetime, timezone
import secrets

from models import db, User
from email_utils import send_verification_email
from cleanup import cleanup_unverified_users

resend_bp = Blueprint("resend", __name__)

@resend_bp.route("/resend-verification", methods=["POST"])
def resend_verification():
    # 🧼 uprac staré neoverené účty
    cleanup_unverified_users()

    data = request.json or {}
    email = (data.get("email") or "").strip()

    if not email:
        return jsonify({"message": "Email is required"}), 400

    user = User.query.filter_by(email=email).first()

    # Bezpečnostne: nech neprezrádza, či email existuje
    # (ale pre školský projekt môžeš aj vracať "not found" - nechávam bezpečnú variantu)
    if not user:
        return jsonify({"message": "If the account exists, verification email was sent."}), 200

    if user.email_verified:
        return jsonify({"message": "Email already verified"}), 200

    # vygeneruj nový token
    token = secrets.token_urlsafe(32)
    user.verification_token = token
    user.verification_sent_at = datetime.now(timezone.utc)
    db.session.commit()

    try:
        send_verification_email(user.email, token)
    except Exception as e:
        return jsonify({
            "message": "Verification email failed to send",
            "error": str(e)
        }), 500

    return jsonify({"message": "Verification email resent"}), 200
