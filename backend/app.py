import os
from dotenv import load_dotenv
from flask import Flask
from models import db
from register import register_bp
from login import login_bp
from sqlalchemy import text

load_dotenv()

app = Flask(__name__)

db_user = os.getenv('DB_USERNAME')
db_password = os.getenv('DB_PASSWORD')
db_name = os.getenv('DB_NAME')
db_host = os.getenv('DB_HOST', 'localhost')
db_port = os.getenv('DB_PORT', 5432)

app.config['SQLALCHEMY_DATABASE_URI'] = f'postgresql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db.init_app(app)
with app.app_context():
    db.create_all()
# Register blueprints
app.register_blueprint(register_bp)
app.register_blueprint(login_bp)

# Test database connection on startup
try:
    with app.app_context():
        with db.engine.connect() as connection:
            result = connection.execute(text("SELECT 1"))
            print("Database connection successful!", list(result))
except Exception as e:
    print("Database connection failed:", e)


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0")
