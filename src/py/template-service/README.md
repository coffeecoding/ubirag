# Template Service

A template FastAPI service for the UbiRAG monorepo.

## Configuration

Configuration is managed centrally in `src/config/template-service.env`. 

For local development, copy the centralized config:
```bash
cp ../../config/template-service.env .env
```

Configuration variables:
- `SERVICE_NAME`: Name of the service (default: template-service)
- `SERVICE_PORT`: Port the service runs on (default: 7000)

## Running locally

From the `src/py` directory:

```bash
# Install dependencies (first time)
uv sync

# Run the service
cd template-service
uv run python main.py
```

## Running with Docker

From the `src/` directory:

```bash
# Start with docker compose
docker compose up -d template-service

# Stop
docker compose down template-service
```

Configuration is provided via environment variables in `docker-compose.yml`, reading from `src/config/template-service.env`.
## Endpoints

- `GET /health` - Health check endpoint
  - Returns: `{"status": "healthy", "service": "<service-name>"}`
