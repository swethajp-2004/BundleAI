# Full Python image so duckdb + matplotlib work reliably
FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1
ENV MPLCONFIGDIR=/tmp/.matplotlib
ENV PORT=3000

WORKDIR /app

# System deps (helps on slim: fonts + minimal render libs)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    ca-certificates \
    fontconfig \
    fonts-dejavu-core \
    && rm -rf /var/lib/apt/lists/*

# Install deps first (cache-friendly)
COPY requirements.txt /app/requirements.txt
RUN python -m pip install --upgrade pip setuptools wheel \
    && pip install --no-cache-dir -r /app/requirements.txt

# Copy app code
COPY . /app

EXPOSE 3000

# Concurrency settings:
# - WEB_CONCURRENCY: number of workers (processes)
# - GUNICORN_THREADS: threads per worker
# Start with 2 workers + 4 threads on small instances; scale up if CPU/RAM allows.
CMD ["sh", "-c", "gunicorn server:app --bind 0.0.0.0:${PORT:-3000} --workers ${WEB_CONCURRENCY:-2} --threads ${GUNICORN_THREADS:-4} --timeout 120"]
