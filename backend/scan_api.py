from __future__ import annotations

from flask import Blueprint, jsonify, request
from sqlalchemy import desc

from auth_utils import auth_required
from models import db, Plant, UserPlant, User

scan_bp = Blueprint('scan_api', __name__)


@scan_bp.route('/api/scan', methods=['POST'])
@auth_required
def scan(user: User):
    """Scan a QR token and record a discovery.

    Request JSON: {"qr_token": "..."}

    Response JSON:
      {
        "plant_id": int,
        "newly_discovered": bool,
        "foundCount": int,
        "lastPlants": [int, int, int]
      }
    """

    data = request.get_json(silent=True) or {}
    qr_token = (data.get('qr_token') or '').strip()
    if not qr_token:
        return jsonify({"message": "qr_token is required"}), 400

    # Only your official QR codes: token must exist in DB
    plant = Plant.query.filter_by(qr_token=qr_token).first()
    if not plant:
        return jsonify({"message": "Invalid QR code"}), 404

    existing = UserPlant.query.filter_by(user_id=user.id, plant_id=plant.id).first()
    newly = False
    if not existing:
        db.session.add(UserPlant(user_id=user.id, plant_id=plant.id))
        db.session.commit()
        newly = True

    # Progress + recently viewed (latest 3)
    found_count = UserPlant.query.filter_by(user_id=user.id).count()
    last = (
        UserPlant.query
        .filter_by(user_id=user.id)
        .order_by(desc(UserPlant.scanned_at))
        .limit(3)
        .all()
    )
    last_ids = [x.plant_id for x in last]

    return jsonify({
        "plant_id": plant.id,
        "newly_discovered": newly,
        "foundCount": found_count,
        "lastPlants": last_ids,
    }), 200
