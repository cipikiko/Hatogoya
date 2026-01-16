from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

db = SQLAlchemy()

class User(db.Model):
    __tablename__ = 'user'

    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.Text, unique=True, nullable=False)
    email = db.Column(db.Text, unique=True, nullable=False)
    password_hash = db.Column(db.Text, nullable=False)
    role = db.Column(db.Text, default='visitor')
    created_at = db.Column(db.DateTime(timezone=True), default=datetime.utcnow)

class Plant(db.Model):
    __tablename__ = 'plants'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.Text, nullable=False)
    description = db.Column(db.Text)
    wiki_url = db.Column(db.Text)
    qr_token = db.Column(db.Text, unique=True, nullable=False)


class UserPlant(db.Model):
    __tablename__ = 'user_plants'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
    plant_id = db.Column(db.Integer, db.ForeignKey('plants.id'))
    scanned_at = db.Column(db.DateTime, default=datetime.utcnow)

class UserPlantView(db.Model):
    __tablename__ = 'user_plant_views'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
    plant_id = db.Column(db.Integer, db.ForeignKey('plants.id'))
    viewed_at = db.Column(db.DateTime, default=datetime.utcnow)
