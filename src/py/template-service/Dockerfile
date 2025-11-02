FROM python:3.12-slim

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

# Copy the service files (paths relative to src/ directory)
COPY py/template-service/pyproject.toml ./
COPY py/template-service/main.py ./
COPY py/template-service/config.py ./

# Install dependencies
RUN uv pip install --system -r pyproject.toml

# Expose the port (will be set by env var, default 7000)
EXPOSE 7000

# Run the service using a shell to expand SERVICE_PORT env var
CMD sh -c 'python -m uvicorn main:app --host 0.0.0.0 --port ${SERVICE_PORT:-7000}'
