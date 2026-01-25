from flask import Blueprint, request, jsonify
from werkzeug.security import check_password_hash

from models import User
from rate_limit import allow, retry_after_seconds  # ✅ rate-limit

login_bp = Blueprint("login", __name__)

@login_bp.route("/login", methods=["POST"])
def login():
    # ✅ Rate-limit: 5 attempts per 5 minutes per IP
    ip = request.headers.get("X-Forwarded-For", request.remote_addr) or "unknown"
    key = f"login:{ip}"
    limit = 5
    window = 300
    if not allow(key, limit=limit, window_seconds=window):
        ra = retry_after_seconds(key, window_seconds=window)
        return jsonify({"message": f"Too many login attempts. Please try again in {ra} seconds."}), 429

    data = request.get_json() or {}
    username = data.get("username")
    password = data.get("password")

    if not username or not password:
        return jsonify({"message": "Username and password are required."}), 400

    user = User.query.filter_by(username=username).first()

    if user and check_password_hash(user.password_hash, password):
        if not user.email_verified:
            return jsonify({"message": "Email not verified."}), 403
        return jsonify({"message": "Login successful", "token": user.username}), 200

    return jsonify({"message": "Invalid credentials."}), 401
