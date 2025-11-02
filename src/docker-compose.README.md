# Docker Compose Configuration

This docker-compose.yml file manages all services in the UbiRAG system.

## Usage

From the `src/` directory:

```bash
# Start a specific service
docker compose up -d <service-name>

# Stop a specific service  
docker compose down <service-name>

# Start all services
docker compose up -d

# Stop all services
docker compose down

# View logs
docker compose logs <service-name>

# Rebuild a service
docker compose build --no-cache <service-name>
docker compose up -d <service-name>
```

## Service Configuration

Each service:
- Is defined with its own configuration block
- Gets environment variables from `config/<service-name>.env`
- Has health checks configured
- Restarts automatically unless stopped manually
- Uses its configured port for both internal and external access

## Adding New Services

When you use `scripts/add-py-service.sh`, the script automatically:
1. Creates the service directory structure
2. Adds the service to this docker-compose.yml
3. Creates the centralized config file
4. Sets up proper port mapping

The port for each service is read from its config file during service creation.

## Available Services

- `template-service` - Template FastAPI service (port 7000)
