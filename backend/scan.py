from flask import Blueprint, request, jsonify
from models import db, Plant, UserPlant, User, UserPlantView

scan_bp = Blueprint('scan', __name__)

@scan_bp.route('/scan', methods=['POST'])
def scan_qr():
    data = request.json
    token = data.get('qr_token')
    user_id = data.get('user_id')

    if not token or not user_id:
        return jsonify({"message": "qr_token and user_id are required"}), 400

    plant = Plant.query.filter_by(qr_token=token).first()
    if not plant:
        return jsonify({"message": "Invalid QR code"}), 400

    exists = UserPlant.query.filter_by(
        user_id=user_id,
        plant_id=plant.id
    ).first()

    if not exists:
        db.session.add(UserPlant(
            user_id=user_id,
            plant_id=plant.id
        ))
        db.session.commit()

    return jsonify({
        "id": plant.id,
        "name": plant.name,
        "wiki": plant.wiki_url
    }), 200


@scan_bp.route('/my-plants/<int:user_id>', methods=['GET'])
def my_plants(user_id):
    plants = db.session.query(Plant).join(UserPlant).filter(
        UserPlant.user_id == user_id
    ).all()

    return jsonify([
        {
            "id": p.id,
            "name": p.name,
            "wiki": p.wiki_url
        }
        for p in plants
    ])


@scan_bp.route('/plant-view', methods=['POST'])
def plant_view():
    data = request.json
    user_id = data.get('user_id')
    plant_id = data.get('plant_id')

    if not user_id or not plant_id:
        return jsonify({"message": "user_id and plant_id are required"}), 400

    plant = Plant.query.get(plant_id)
    if not plant:
        return jsonify({"message": "Plant not found"}), 404

    view = UserPlantView(
        user_id=user_id,
        plant_id=plant_id
    )

    db.session.add(view)
    db.session.commit()

    return jsonify({"message": "View saved"}), 201


@scan_bp.route('/recent-plants/<int:user_id>', methods=['GET'])
def recent_plants(user_id):
    views = (
        db.session.query(Plant)
        .join(UserPlantView, Plant.id == UserPlantView.plant_id)
        .filter(UserPlantView.user_id == user_id)
        .order_by(UserPlantView.viewed_at.desc())
        .limit(3)
        .all()
    )

    return jsonify([
        {
            "id": p.id,
            "name": p.name,
            "wiki": p.wiki_url
        } for p in views
    ])

@scan_bp.route('/user-progress/<int:user_id>', methods=['GET'])
def user_progress(user_id):
    total = Plant.query.count()
    discovered = UserPlant.query.filter_by(user_id=user_id).count()

    return jsonify({
        "discovered": discovered,
        "total": total
    })


@scan_bp.route('/plants', methods=['GET'])
def get_plants():
    user_id = request.args.get('user_id', type=int)
    filter_type = request.args.get('filter', default='all')

    if not user_id:
        return jsonify({"message": "user_id is required"}), 400

    if filter_type == 'discovered':
        plants = (
            Plant.query
            .join(UserPlant)
            .filter(UserPlant.user_id == user_id)
            .all()
        )

    elif filter_type == 'undiscovered':
        subquery = (
            db.session.query(UserPlant.plant_id)
            .filter(UserPlant.user_id == user_id)
        )
        plants = Plant.query.filter(~Plant.id.in_(subquery)).all()

    else:  # all
        plants = Plant.query.all()

    return jsonify([
        {
            "id": p.id,
            "name": p.name,
            "wiki": p.wiki_url
        } for p in plants
    ])
