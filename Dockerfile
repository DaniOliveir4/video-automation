import os
import sys
from flask import Flask, jsonify

# DON'T CHANGE THIS !!!
# garante que o pacote "src" seja encontrado
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

# .env (opcional)
try:
    from dotenv import load_dotenv
    load_dotenv()
except Exception:
    pass

# App
app = Flask(__name__)

# Config
from src.config import Config as _Config
config = _Config()
app.config.from_object(config)

# Extensões
from src.extensions.db import db
from src.extensions.cors import init_cors
init_cors(app, origins=app.config.get("CORS_ORIGINS", "*"))
db.init_app(app)

# Blueprints
from src.blueprints.auth import auth_bp
from src.blueprints.content import content_bp
from src.blueprints.download import download_bp
from src.blueprints.system import system_bp
from src.blueprints.generate import generate_bp
from src.blueprints.upload import upload_bp

app.register_blueprint(auth_bp, url_prefix="/api")
app.register_blueprint(content_bp, url_prefix="/api")
app.register_blueprint(download_bp, url_prefix="/api")
app.register_blueprint(system_bp, url_prefix="/api")
app.register_blueprint(generate_bp, url_prefix="/api")
app.register_blueprint(upload_bp, url_prefix="/api")

# DB (cria tabelas se ainda não existirem)
with app.app_context():
    from src import models  # registra modelos
    db.create_all()

# Healthcheck
@app.route("/health")
def health():
    return jsonify({"status": "ok"}), 200

if __name__ == "__main__":
    # Scheduler (não bloqueia)
    try:
        from src.services.scheduler.automation_scheduler import start_scheduler
        start_scheduler()
        print("✅ Scheduler started")
    except Exception as e:
        print(f"⚠️ Scheduler not started: {e}")

    print(f"🚀 Starting server on {config.HOST}:{config.PORT} (debug={config.DEBUG})")
    app.run(host=config.HOST, port=config.PORT, debug=config.DEBUG)
