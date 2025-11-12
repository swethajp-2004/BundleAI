# Use official Python slim
FROM python:3.11-slim

# avoid buffering
ENV PYTHONUNBUFFERED=1

# set working dir
WORKDIR /app

# system deps for pyodbc / ODBC driver (Debian-based)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    gnupg \
    curl \
    unixodbc-dev \
    apt-transport-https \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Microsoft ODBC Driver for SQL Server (ODBC Driver 18)
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
 && curl https://packages.microsoft.com/config/debian/12/prod.list > /etc/apt/sources.list.d/mssql-release.list \
 && apt-get update \
 && ACCEPT_EULA=Y apt-get install -y msodbcsql18

# copy and install python requirements
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# copy app files
COPY . .

# expose the port (Render sets $PORT already)
ENV PORT=3000

# run gunicorn
CMD ["gunicorn", "server:app", "--bind", "0.0.0.0:3000", "--workers", "4", "--threads", "2"]
