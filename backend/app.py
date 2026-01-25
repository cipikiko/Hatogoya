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
from scan_api import scan_bp
from profile_api import profile_bp

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


def ensure_plants_table_columns():
    # ak máš už tabuľku plants a len dopĺňaš stĺpce
    db.session.execute(text("""
        ALTER TABLE plants
        ADD COLUMN IF NOT EXISTS name TEXT;
    """))
    db.session.execute(text("""
        ALTER TABLE plants
        ADD COLUMN IF NOT EXISTS description TEXT;
    """))
    db.session.execute(text("""
        ALTER TABLE plants
        ADD COLUMN IF NOT EXISTS qr_token TEXT;
    """))
    db.session.execute(text("""
        ALTER TABLE plants
        ADD COLUMN IF NOT EXISTS asset_path TEXT;
    """))
    db.session.execute(text("""
        CREATE UNIQUE INDEX IF NOT EXISTS ux_plants_qr_token ON plants(qr_token);
    """))
    db.session.commit()


def seed_plants():
    plants = [
        # id, name, description, qr_token, asset_path
        # description si daj podľa toho čo máte v DB / alebo prázdne dočasne
        (1, 'Cornus controversa Variegata', 'A striking variegated dogwood with layered, horizontal branching. The creamy-white foliage brightens shady areas and looks elegant in spring. It forms a sculptural crown as it matures.', 'p01__eOlxYmCUB7Rlg', 'lib/utils/plants/Cornus controversa.jpg'),
        (2, 'Sciadopitys verticillata Wiels Beauty', 'Japanese umbrella pine is a rare conifer with unique whorled needles. Wiels Beauty is valued for its dense habit and refined texture.', 'p02_yyDDdTN_GrwOkg', 'lib/utils/plants/Sciadopitys verticillata Wiels Beauty.jpg'),
        (3, 'Cedrus atlantica Glauca', 'Atlas cedar Glauca is famous for its silvery-blue needles and strong architectural form.', 'p03_MGIS1H1AeGF7yQ', 'lib/utils/plants/Cedrus atlantica Glauca.jpg'),
        (4, 'Camellia japonica', 'Camellia japonica is an evergreen shrub with glossy leaves and elegant flowers.', 'p04_9YIrDN6C2ADx3Q', 'lib/utils/plants/Camellia japonica.jpg'),
        (5, 'Ginkgo biloba China Pendula', 'A weeping form of ginkgo with fan-shaped leaves and graceful habit.', 'p05_ZvJPmqpJoI6oMQ', 'lib/utils/plants/Ginkgo biloba China Pendula.jpg'),
        (6, 'Acer japonica Orange Dream', 'A compact Japanese maple with bright foliage that shifts through the seasons.', 'p06_EwNOSSzoXo22gw', 'lib/utils/plants/Acer japonica Orange Dream.jpg'),
        (7, 'Ginkgo biloba Mariken', 'A dwarf ginkgo with a rounded crown and small fan-shaped leaves.', 'p07_aSJTbtz2ihQuSw', 'lib/utils/plants/Ginkgo biloba Mariken.jpg'),
        (8, 'Cedrus deodara Aurea', 'A golden-needled deodar cedar adding warm color year-round.', 'p08_N0NDdgikd_PbzQ', 'lib/utils/plants/Cedrus deodara Aurea.jpg'),
        (9, 'Cedrus atlantica Glauca Pendula', 'A dramatic weeping blue Atlas cedar with cascading branches.', 'p09_QAb330mU1dc2yw', 'lib/utils/plants/Cedrus atlantica Glauca Pendula.jpg'),
        (10, 'Sequoiadendron giganteum', 'One of the most massive tree species on Earth, grown for its grand form.', 'p10_4wdmuBELN2YQBw', 'lib/utils/plants/Sequoiadendron giganteum.jpg'),
        (11, 'Sequoia sempervirens Loma Prieta Spike', 'A narrow upright coastal redwood selection.', 'p11_EopfEQQyP1FTZw', 'lib/utils/plants/Sequoia sempervirens Loma Prieta Spike.jpg'),
        (12, 'Pinus sabiniana Isabella', 'Gray pine with long drooping needles and open habit.', 'p12_nDiIlA_qfesTkA', 'lib/utils/plants/Pinus sabiniana Isabella.JPG'),
        (13, 'Cornus venus', 'Hybrid dogwood with large white bracts and good resilience.', 'p13_czvQ6P86w9Gm3g', 'lib/utils/plants/Cornus kousa Venus.jpg'),
        (14, 'Liquidambar styraciflua', 'Sweetgum prized for star-shaped leaves and autumn color.', 'p14_hA7utrvtPkwzmw', 'lib/utils/plants/Liquidambar styraciflua.jpg'),
        (15, 'Magnolia Coral Lake', 'Magnolia with showy spring flowers and balanced form.', 'p15_zp3V3_lIeNmAiQ', 'lib/utils/plants/Magnolia Coral Lake.JPG'),
        (16, 'Magnolia grandiflora Kay Parris', 'Evergreen magnolia with fragrant white flowers.', 'p16_nB_XXU9a3kd1mA', 'lib/utils/plants/Magnolia grandiflora Kay Parris.JPG'),
        (17, 'Pinus nigra', 'A tough pine with dark green needles and adaptable growth.', 'p17_dLIdFBSkgGGSkg', 'lib/utils/plants/Pinus nigra.jpg'),
        (18, 'Liriodendron tulipifera', 'Tall deciduous tree with tulip-like flowers.', 'p18_8lZ2GBmiYY-V-A', 'lib/utils/plants/Liriodendron tulipifera.jpg'),
        (19, 'Sequoia sempervirens Winter Blue', 'Redwood cultivar with bluish foliage tones.', 'p19_oC2juyAKPb09Ng', 'lib/utils/plants/Sequoia sempervirens Winter Blue.jpg'),
        (20, 'Abies koreana Kosmos', 'Compact Korean fir with decorative cones.', 'p20_hsuRYAsph7CJPA', 'lib/utils/plants/Abies koreana Kosmos.jpg'),
        (21, 'Sequoia sempervirens Xeno', 'Redwood selection with strong ornamental value.', 'p21_9zAYBDaWGWAZog', 'lib/utils/plants/Sequoia sempervirens Xeno.jpg'),
        (22, 'Abies vejarii Mountain Blue', 'Blue-toned fir valued for dense needles.', 'p22_b65lcjlE7YAZJw', 'lib/utils/plants/Abies vejarii Mountain Blue.jpg'),
        (23, 'Magnolia denudata Yellow River', 'Magnolia producing elegant early-season flowers.', 'p23_ikaFoxX_uM8bzQ', 'lib/utils/plants/Magnolia denudata Yellow River.jpg'),
        (24, 'Fagus sylvatica Black Swan', 'Weeping European beech with dark foliage.', 'p24_kARW0SgpIAKSEQ', 'lib/utils/plants/Fagus sylvatica Black Swan.jpg'),
        (25, 'Quercus frainetto', 'Hungarian oak forming a broad impressive crown.', 'p25_C4Wjn8-gYvb8rQ', 'lib/utils/plants/Quercus frainetto.jpg'),
        (26, 'Platanus acerifolia', 'London plane, a hardy urban tree with peeling bark.', 'p26_QcPlQ5MqLFYXww', 'lib/utils/plants/Platanus acerifolia.jpg'),
    ]

    # UPSERT: ak existuje id, tak update; inak insert
    for (pid, name, desc, qr, asset) in plants:
        db.session.execute(
            text("""
                INSERT INTO plants (id, name, description, qr_token, asset_path)
                VALUES (:id, :name, :description, :qr_token, :asset_path)
                ON CONFLICT (id) DO UPDATE SET
                    name = EXCLUDED.name,
                    description = EXCLUDED.description,
                    qr_token = EXCLUDED.qr_token,
                    asset_path = EXCLUDED.asset_path;
            """),
            {
                "id": pid,
                "name": name,
                "description": desc,
                "qr_token": qr.strip(),
                "asset_path": asset,
            }
        )

    db.session.execute(text("""
        SELECT setval(
            pg_get_serial_sequence('plants','id'),
            (SELECT COALESCE(MAX(id), 1) FROM plants)
        );
    """))
    db.session.commit()




with app.app_context():
    db.create_all()
    ensure_user_table_columns()
    ensure_plants_table_columns()
    seed_plants()
    cleanup_unverified_users()

# Register blueprints
app.register_blueprint(register_bp)
app.register_blueprint(login_bp)
app.register_blueprint(verify_bp)
app.register_blueprint(resend_bp)
app.register_blueprint(reset_bp)  # ✅ pridane
app.register_blueprint(scan_bp)
app.register_blueprint(profile_bp)

# Test database connection on startup
try:
    with app.app_context():
        with db.engine.connect() as connection:
            result = connection.execute(text("SELECT 1"))
            print("Database connection successful!", list(result))
except Exception as e:
    print("Database connection failed:", e)

@app.route("/")
def index():
    return {"message": "Backend is running OK"}


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0")
