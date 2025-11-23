from flask import Blueprint, request, jsonify
from models import db, User
from werkzeug.security import check_password_hash

login_bp = Blueprint('login', __name__)

@login_bp.route('/login', methods=['POST'])
def login():
    data = request.json
    email = data.get('email')
    password = data.get('password')

    user = User.query.filter_by(email=email).first()

    if not email or not password:
        return jsonify({"message": "Email and password are required"}), 400

    if user and check_password_hash(user.password_hash, password):
        return jsonify({
            "message": "Login successful"
        }), 200

    return jsonify({"message": "Invalid credentials"}), 401
