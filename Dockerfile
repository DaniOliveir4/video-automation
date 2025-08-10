# Usa Python slim e instala o que vamos precisar
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

# deps de sistema: unzip p/ extrair o ZIP, rclone/ffmpeg p/ subir p/ Drive e render futuro
RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip rclone ffmpeg tzdata && \
    rm -rf /var/lib/apt/lists/*

# Copia TODO o repo (inclui seu ZIP)
WORKDIR /srcrepo
COPY . .

# Descompacta o ZIP p/ /app
RUN mkdir -p /app && \
    ZIP=$(ls /srcrepo/video_automation_project_*.zip | head -n1) && \
    unzip -o "$ZIP" -d /app && \
    mkdir -p /app/output/videos /app/database && \
    chmod +x /app/entrypoint.sh || true

WORKDIR /app

# Instala as dependências do projeto (estão dentro do ZIP)
RUN pip install -r requirements.txt

EXPOSE 8000
CMD ["/app/entrypoint.sh"]
