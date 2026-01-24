from __future__ import annotations

from flask import Blueprint, jsonify
from sqlalchemy import desc

from auth_utils import auth_required
from models import UserPlant, User

profile_bp = Blueprint('profile_api', __name__)

@profile_bp.route('/api/profile', methods=['GET'])
@auth_required
def profile(user: User):
    q = UserPlant.query.filter_by(user_id=user.id)

    found_count = q.count()

    last = (
        q.order_by(desc(UserPlant.scanned_at))
         .limit(3)
         .all()
    )

    discovered_all = q.all()

    return jsonify({
        "foundCount": found_count,
        "lastPlants": [x.plant_id for x in last],
        "discoveredPlantIds": [x.plant_id for x in discovered_all],
    }), 200
