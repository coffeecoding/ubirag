#!/bin/bash
# Script to add a new Python-based service to the UbiRAG monorepo
# Usage: ./add-py-service.sh <service-name>

set -e

# Check if service name is provided
if [ -z "$1" ]; then
    echo "Error: Service name is required"
    echo "Usage: ./add-py-service.sh <service-name>"
    exit 1
fi

SERVICE_NAME="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PY_DIR="$SCRIPT_DIR/../py"
CONFIG_DIR="$SCRIPT_DIR/../config"
TEMPLATE_DIR="$PY_DIR/template-service"
NEW_SERVICE_DIR="$PY_DIR/$SERVICE_NAME"

# Check if template service exists
if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "Error: Template service not found at $TEMPLATE_DIR"
    exit 1
fi

# Check if service already exists
if [ -d "$NEW_SERVICE_DIR" ]; then
    echo "Error: Service '$SERVICE_NAME' already exists at $NEW_SERVICE_DIR"
    exit 1
fi

echo "Creating new service: $SERVICE_NAME"

# Copy template service
cp -r "$TEMPLATE_DIR" "$NEW_SERVICE_DIR"
echo "✓ Copied template service to $NEW_SERVICE_DIR"

# Update pyproject.toml with new service name
sed -i "s/name = \"template-service\"/name = \"$SERVICE_NAME\"/" "$NEW_SERVICE_DIR/pyproject.toml"
sed -i "s/description = \"Template service for UbiRAG\"/description = \"$SERVICE_NAME service for UbiRAG\"/" "$NEW_SERVICE_DIR/pyproject.toml"
echo "✓ Updated service pyproject.toml"

# Update .env.example with new service name
sed -i "s/SERVICE_NAME=template-service/SERVICE_NAME=$SERVICE_NAME/" "$NEW_SERVICE_DIR/.env.example"
echo "✓ Updated .env.example"

# Update config.py default service name
sed -i "s/service_name: str = \"template-service\"/service_name: str = \"$SERVICE_NAME\"/" "$NEW_SERVICE_DIR/config.py"
echo "✓ Updated config.py"

# Update README.md
sed -i "s/Template Service/$(echo $SERVICE_NAME | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')/" "$NEW_SERVICE_DIR/README.md"
sed -i "s/template-service/$SERVICE_NAME/g" "$NEW_SERVICE_DIR/README.md"
echo "✓ Updated README.md"

# Update Dockerfile with new service name
sed -i "s/template-service/$SERVICE_NAME/g" "$NEW_SERVICE_DIR/Dockerfile"
echo "✓ Updated Dockerfile"

# Create centralized config file
if [ -d "$CONFIG_DIR" ]; then
    cp "$CONFIG_DIR/template-service.env" "$CONFIG_DIR/$SERVICE_NAME.env"
    sed -i "s/SERVICE_NAME=template-service/SERVICE_NAME=$SERVICE_NAME/" "$CONFIG_DIR/$SERVICE_NAME.env"
    echo "✓ Created centralized config at $CONFIG_DIR/$SERVICE_NAME.env"
else
    echo "⚠ Warning: Config directory not found at $CONFIG_DIR"
fi

# Update workspace pyproject.toml to include the new service
WORKSPACE_PYPROJECT="$PY_DIR/pyproject.toml"
if [ -f "$WORKSPACE_PYPROJECT" ]; then
    # Check if the service is already in the members list
    if ! grep -q "\"$SERVICE_NAME\"" "$WORKSPACE_PYPROJECT"; then
        # Add the new service to the members array
        # Find the line with 'members = [' and add the new service
        if grep -q '^members = \["template-service"\]' "$WORKSPACE_PYPROJECT"; then
            # Replace single-item array with multi-item
            sed -i "s/^members = \[\"template-service\"\]/members = [\"template-service\", \"$SERVICE_NAME\"]/" "$WORKSPACE_PYPROJECT"
        else
            # Add to existing multi-item array (before closing bracket)
            sed -i "/^members = \[/s/\]/, \"$SERVICE_NAME\"]/" "$WORKSPACE_PYPROJECT"
        fi
        echo "✓ Added $SERVICE_NAME to workspace members"
    else
        echo "⚠ Service already in workspace members"
    fi
else
    echo "⚠ Warning: Workspace pyproject.toml not found at $WORKSPACE_PYPROJECT"
fi

# Add service to docker-compose.yml
DOCKER_COMPOSE="$SCRIPT_DIR/../docker-compose.yml"
if [ -f "$DOCKER_COMPOSE" ]; then
    # Check if service already exists in docker-compose
    if ! grep -q "^  $SERVICE_NAME:" "$DOCKER_COMPOSE" ]; then
        # Read the port from the config file
        SERVICE_PORT=$(grep "^SERVICE_PORT=" "$CONFIG_DIR/$SERVICE_NAME.env" | cut -d= -f2)
        : ${SERVICE_PORT:=7000}  # Default to 7000 if not found
        
        # Append new service definition to docker-compose.yml
        cat >> "$DOCKER_COMPOSE" <<EOF

  $SERVICE_NAME:
    build:
      context: .
      dockerfile: py/$SERVICE_NAME/Dockerfile
    image: $SERVICE_NAME:latest
    container_name: $SERVICE_NAME
    environment:
      - SERVICE_NAME=$SERVICE_NAME
      - SERVICE_PORT=$SERVICE_PORT
    ports:
      - "$SERVICE_PORT:$SERVICE_PORT"
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:$SERVICE_PORT/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
EOF
        echo "✓ Added $SERVICE_NAME to docker-compose.yml (port: $SERVICE_PORT)"
    else
        echo "⚠ Service already in docker-compose.yml"
    fi
else
    echo "⚠ Warning: docker-compose.yml not found at $DOCKER_COMPOSE"
fi

echo ""
echo "✅ Service '$SERVICE_NAME' created successfully!"
echo ""
echo "Next steps:"
echo "  1. Configure service in $CONFIG_DIR/$SERVICE_NAME.env (set SERVICE_PORT if needed)"
echo "  2. Customize the service implementation in $NEW_SERVICE_DIR/main.py"
echo "  3. From $SCRIPT_DIR/.., run: uv sync (in py/ directory)"
echo ""
echo "Run locally:"
echo "  cd $NEW_SERVICE_DIR && cp ../../config/$SERVICE_NAME.env .env && uv run python main.py"
echo ""
echo "Run with Docker:"
echo "  cd $SCRIPT_DIR/.. && docker compose up -d $SERVICE_NAME"
