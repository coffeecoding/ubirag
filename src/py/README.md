# UbiRAG Python Services

This directory contains all Python-based microservices for the UbiRAG system, managed as a uv workspace.

## Structure

- `pyproject.toml` - Workspace configuration managing all services
- `template-service/` - Template service that can be cloned for new services
- `lib/` - Shared Python libraries (future use)

## Prerequisites

- [uv](https://github.com/astral-sh/uv) - Fast Python package installer and resolver
- Docker (for containerization)
- Python 3.12+

## Getting Started

### Initial Setup

From this directory (`src/py`), initialize the workspace:

```bash
uv sync
```

This will:
- Create a virtual environment at `.venv`
- Install all dependencies for workspace members
- Set up the development environment

### Creating a New Service

Use the provided script to create a new service from the template:

```bash
cd ../scripts
./add-py-service.sh <service-name>
```

For example:
```bash
./add-py-service.sh user-service
```

This will:
1. Clone the template service
2. Update service-specific configuration files
3. Add the new service to the workspace members
4. Provide instructions for next steps

After creating a service:
```bash
cd src/py
uv sync  # Install dependencies for the new service
cd <service-name>
cp ../../config/<service-name>.env .env  # Copy centralized config
uv run python main.py  # Run the service
```

### Running Services

#### Local Development

From the service directory:
```bash
cd <service-name>
uv run python main.py
```

The service will run with hot-reload enabled (changes trigger restart).

#### Docker

From the service directory:
```bash
docker build -t <service-name> .
docker run -p 8000:8000 <service-name>
```

Adjust the port mapping (`-p`) based on your service configuration.

## Template Service

The `template-service` provides a minimal FastAPI application with:
- Configuration via environment variables (using pydantic-settings)
- A `/health` endpoint returning service status
- Docker support with centralized configuration
- Ready-to-use structure for new services

### Configuration

Service configurations are managed centrally in `src/config/`:
- Each service has a `<service-name>.env` file
- Configuration is automatically used in Docker builds
- For local development, copy the centralized config to `.env`

Common configuration variables:
- `SERVICE_NAME` - Identifier for the service
- `SERVICE_PORT` - Port the service listens on (template: 7000)

## Workspace Management

The `pyproject.toml` at this level defines the workspace. New services are automatically added to the `members` list by the `add-py-service.sh` script.

### Adding Dependencies

For a specific service:
```bash
cd <service-name>
uv add <package-name>
```

For workspace-wide dev dependencies:
```bash
# Edit pyproject.toml and add to [dependency-groups] dev
uv sync
```

### Updating Dependencies

```bash
uv lock --upgrade  # Update lock file
uv sync  # Install updated dependencies
```

## Best Practices

1. **Centralized Configuration**: All service configs live in `src/config/` for easy management
2. **Environment Variables**: Use `.env` files locally (gitignored), never commit secrets
3. **Configuration**: Use pydantic-settings for type-safe configuration management
4. **Service Structure**: Keep services focused and independent
5. **Shared Code**: Place reusable code in `lib/` and reference it in service dependencies
6. **Docker**: Test Docker builds regularly to ensure deployment readiness

## Shared Libraries

The `lib/` directory is reserved for shared Python code used across multiple services. To use shared libraries:

1. Create a package in `lib/<package-name>`
2. Add it to workspace members in `pyproject.toml`
3. Reference it in service dependencies

(To be implemented as needed)
