#!/bin/bash
# bootstrap.sh - Bootstraps a new Next.js application
# This script runs from the app repository root during initialization
# It builds the Dockerfile.init container and extracts the generated code

set -e  # Exit on error
set -u  # Exit on undefined variable

echo "[INFO] Starting Next.js application bootstrap"

# Validate required environment variables
REQUIRED_VARS=(
  "APP_NAME"
  "APP_DOMAIN"
  "APP_PORT"
  "APP_SERVICE"
  "APP_STACK"
  "APP_TYPE"
)

echo "[INFO] Validating required environment variables"
for var in "${REQUIRED_VARS[@]}"; do
  if [ -z "${!var:-}" ]; then
    echo "[ERROR] Required variable $var is not set"
    exit 1
  fi
done

echo "[INFO] Configuration:"
echo "  APP_NAME: ${APP_NAME}"
echo "  APP_DOMAIN: ${APP_DOMAIN}"
echo "  APP_PORT: ${APP_PORT}"
echo "  APP_TYPE: ${APP_TYPE}"

# Clean any existing artifacts from previous runs
echo "[INFO] Cleaning workspace from previous runs"
rm -rf frontend/ 2>/dev/null || true

# Verify Dockerfile.init exists in current directory
if [ ! -f "Dockerfile.init" ]; then
  echo "[ERROR] Dockerfile.init not found in current directory"
  exit 1
fi

# Build the init container
echo "[INFO] Building init container to generate source code"
docker build -f Dockerfile.init \
  --build-arg APP_NAME="${APP_NAME}" \
  -t ${APP_NAME}-init:latest .

# Create temporary container and extract generated code
echo "[INFO] Extracting generated code from container"
container_id=$(docker create ${APP_NAME}-init:latest)

# Create frontend directory and copy app code there
echo "[INFO] Creating frontend directory and copying application code"
mkdir -p frontend
docker cp ${container_id}:/app/. ./frontend/

# Cleanup container
docker rm ${container_id}
echo "[INFO] Cleaned up temporary container"

# Move README.md to repository root if it exists
echo "[INFO] Organizing repository structure"
if [ -f "frontend/README.md" ]; then
  mv frontend/README.md ./ 2>/dev/null || true
  echo "  Moved README.md to root"
fi

# Remove bootstrap artifacts (keep .gitignore, Dockerfile, compose files)
echo "[INFO] Cleaning up bootstrap artifacts"
rm -f Dockerfile.init bootstrap.sh 2>/dev/null || true

# Summary
echo ""
echo "[SUCCESS] Next.js application bootstrap complete!"
echo ""
echo "Generated structure:"
echo "  frontend/          - Next.js application code"
echo "  Dockerfile         - Production Dockerfile (in root)"
echo "  .gitignore         - Git ignore patterns"
echo "  README.md          - Project documentation"
echo ""
echo "Next steps:"
echo "  1. Review the generated code in frontend/"
echo "  2. Run 'cd frontend && npm run dev' to start development server"
echo ""
