import uuid
import qrcode
import os
from app import app, db
from models import Plant

plants = [
    {"name": "Cornus controversa Variegata"},
    {"name": "Sciadopitys verticillata"},
    {"name": "Cedrus atlantica Glauca"},
    {"name": "Camellia japonica"},
    {"name": "Ginkgo biloba China Pendula"},
    {"name": "Acer japonica Orange Dream"},
    {"name": "Ginkgo biloba Mariken"},
    {"name": "Cedrus deodara Aurea"},
    {"name": "Cedrus atlantica Glauca Pendula"},
    {"name": "Sequoiadendron giganteum"},
    {"name": "Sequoia sempervirens Loma Prieta Spike"},
    {"name": "Pinus sabiniana"},
    {"name": "Cornus hybrid"},
    {"name": "Liquidambar styraciflua"},
    {"name": "Magnolia x Coral Lake"},
    {"name": "Magnolia grandiflora Kay Parris"},
    {"name": "Pinus nigra"},
    {"name": "Liriodendron tulipifera"},
    {"name": "Sequoia sempervirens Winter Blue"},
    {"name": "Abies koreana Kosmos"},
    {"name": "Sequoia sempervirens Xeno"},
    {"name": "Abies vejarii Mountain Blue"},
    {"name": "Magnolia denudata Yellow River"},
    {"name": "Fagus sylvatica Black Swan"},
    {"name": "Quercus frainetto"},
    {"name": "Platanus x acerifolia"},
    {"name": "Cedrus atlantica Glauca"}
]

os.makedirs("qr_codes", exist_ok=True)

with app.app_context():
    for p in plants:
        token = str(uuid.uuid4())

        plant = Plant(
            name=p["name"],
            qr_token=token
        )

        db.session.add(plant)
        db.session.commit()

        img = qrcode.make(token)
        filename = p['name'].replace(" ", "_") + ".png"
        img.save(f"qr_codes/{filename}")

        print(f"Created QR for {p['name']} with token {token}")
