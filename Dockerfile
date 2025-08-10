# Base Python
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8000 \
    HOST=0.0.0.0 \
    TZ=America/Sao_Paulo \
    DRIVE_UPLOAD_ENABLED=false \
    DRIVE_PROVIDER=rclone \
    RCLONE_REMOTE=gdrive \
    RCLONE_BASEDIR=Videos \
    VIDEO_OUTPUT_DIR=/app/output/videos

# deps de sistema: unzip (pra extrair o ZIP), rclone/ffmpeg (upload e render futuro)
RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip rclone ffmpeg tzdata ca-certificates curl && \
    rm -rf /var/lib/apt/lists/*

# Copia TODO o repo (inclui o ZIP que você subiu)
WORKDIR /srcrepo
COPY . .

# Descompacta o ZIP para /app e prepara pastas
RUN set -eux; \
    mkdir -p /app; \
    ZIPFILE="$(ls /srcrepo/*.zip | head -n1)"; \
    unzip -o "$ZIPFILE" -d /app; \
    mkdir -p /app/output/videos /app/database; \
    # garante permissão de execução do entrypoint
    chmod +x /app/entrypoint.sh || true

# Instala dependências do projeto (que vieram no ZIP)
WORKDIR /app
RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 8000

# Chama o entrypoint via bash (evita "exec format error")
ENTRYPOINT ["bash", "/app/entrypoint.sh"]
