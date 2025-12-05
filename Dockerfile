# Full Python image so duckdb + matplotlib work reliably
FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1
ENV MPLCONFIGDIR=/tmp/.matplotlib
ENV PORT=3000

WORKDIR /app

# Optional but helpful system deps (matplotlib wheels usually work without these,
# but this reduces "random font/renderer" issues on slim images)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install deps first (cache-friendly)
COPY requirements.txt /app/requirements.txt
RUN python -m pip install --upgrade pip setuptools wheel \
    && pip install --no-cache-dir -r /app/requirements.txt \
    && pip install --no-cache-dir gunicorn

# Copy app code
COPY . /app

EXPOSE 3000

# Concurrency settings:
# - workers: number of processes
# - threads: concurrency inside each worker (good because you wait on OpenAI + DB IO)
# Start with 2-4 workers and 4-8 threads depending on your Render instance size.
CMD ["sh", "-c", "gunicorn server:app --bind 0.0.0.0:${PORT} --workers ${WEB_CONCURRENCY:-4} --threads ${GUNICORN_THREADS:-8} --timeout 120"]
