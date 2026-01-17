import os
from dotenv import load_dotenv
from flask import Flask
from sqlalchemy import text

from models import db
from register import register_bp
from login import login_bp
from verify_email import verify_bp  # ✅ pridane
from resend_verification import resend_bp
from cleanup import cleanup_unverified_users
from password_reset import reset_bp

load_dotenv()

app = Flask(__name__)

db_user = os.getenv('DB_USERNAME')
db_password = os.getenv('DB_PASSWORD')
db_name = os.getenv('DB_NAME')
db_host = os.getenv('DB_HOST', 'localhost')
db_port = os.getenv('DB_PORT', 5432)

app.config['SQLALCHEMY_DATABASE_URI'] = (
    f'postgresql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}'
)
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db.init_app(app)

def ensure_user_table_columns():
    """
    Doplni (ak chybaju) stlpce pre email verification do existujucej tabulky "user".
    Bezpecne je to spustat pri kazdom starte (IF NOT EXISTS).
    """
    db.session.execute(text("""
        ALTER TABLE "user"
        ADD COLUMN IF NOT EXISTS email_verified BOOLEAN NOT NULL DEFAULT FALSE;
    """))

    db.session.execute(text("""
        ALTER TABLE "user"
        ADD COLUMN IF NOT EXISTS verification_token TEXT;
    """))

    db.session.execute(text("""
        ALTER TABLE "user"
        ADD COLUMN IF NOT EXISTS verification_sent_at TIMESTAMPTZ;
    """))

    db.session.execute(text("""
    ALTER TABLE "user"
    ADD COLUMN IF NOT EXISTS reset_token TEXT;
    """))

    db.session.execute(text("""
    ALTER TABLE "user"
    ADD COLUMN IF NOT EXISTS reset_sent_at TIMESTAMPTZ;
    """))

    db.session.commit()

with app.app_context():
    db.create_all()
    ensure_user_table_columns()
    cleanup_unverified_users()

# Register blueprints
app.register_blueprint(register_bp)
app.register_blueprint(login_bp)
app.register_blueprint(verify_bp)
app.register_blueprint(resend_bp)
app.register_blueprint(reset_bp)  # ✅ pridane

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
