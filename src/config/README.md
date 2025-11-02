# Service Configuration Files

This directory contains environment configuration files for all services in the UbiRAG system.

## Structure

Each service has its own configuration file named `<service-name>.env`:
- `template-service.env` - Template service configuration

## Usage

### Local Development
Copy the relevant config file to your service's `.env`:
```bash
cp ../../config/<service-name>.env .env
```

### Docker
The Dockerfile automatically copies the appropriate config file from this centralized location.

### Adding New Services
When creating a new service, create a corresponding `<service-name>.env` file here with the service's configuration.

## Configuration Variables

Common variables across services:
- `SERVICE_NAME` - Unique identifier for the service
- `SERVICE_PORT` - Port the service listens on

Service-specific variables should be documented in the service's README.
