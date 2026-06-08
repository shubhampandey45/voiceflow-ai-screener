# Stage 1: Build dependencies
FROM python:3.11-slim as builder

WORKDIR /app

# Install system dependencies needed for compiling package assets (e.g. for PostgreSQL if using raw psycopg2)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Stage 2: Runtime production image
FROM python:3.11-slim as runner

WORKDIR /app

# Install runtime PostgreSQL library dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Copy compiled python wheels/dependencies from builder stage
COPY --from=builder /root/.local /root/.local
COPY . /app

# Ensure locally installed pip binaries are available in PATH
ENV PATH=/root/.local/bin:$PATH
ENV PYTHONUNBUFFERED=1

EXPOSE 8000
EXPOSE 7860

# Start app using uvicorn with production worker settings, respecting the PORT environment variable
CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000} --workers 4"]
