#!/bin/bash
#
# Build script for Sunbird Garden Docker images
# Usage: ./scripts/build-images.sh [VERSION]
#
# Examples:
#   ./scripts/build-images.sh        # Build with 'latest' tag
#   ./scripts/build-images.sh 1.0.0  # Build with version 1.0.0
#

set -e

# Configuration
DOCKER_NAMESPACE="progalaxyelabs"
PROJECT_NAME="stonescriptphp-sunbird-garden"

# Service configurations
SERVICES=("api" "www" "alert")

# Get version from argument or use 'latest'
VERSION="${1:-latest}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "${GREEN}Building Sunbird Garden Docker Images${NC}"
echo "=========================================="
echo "Namespace:     ${DOCKER_NAMESPACE}"
echo "Project:       ${PROJECT_NAME}"
echo "Tag Version:   ${VERSION}"
echo "Services:      ${SERVICES[@]}"
echo "=========================================="
echo ""

# Build each service
for SERVICE in "${SERVICES[@]}"; do
    IMAGE_NAME="${PROJECT_NAME}-${SERVICE}"
    SERVICE_DIR="${PROJECT_ROOT}/${SERVICE}"

    if [ ! -d "$SERVICE_DIR" ]; then
        echo -e "${RED}✗ Service directory not found: ${SERVICE_DIR}${NC}"
        continue
    fi

    if [ ! -f "${SERVICE_DIR}/Dockerfile" ]; then
        echo -e "${RED}✗ Dockerfile not found in: ${SERVICE_DIR}${NC}"
        continue
    fi

    echo -e "${BLUE}Building ${SERVICE} service...${NC}"
    echo "  Directory: ${SERVICE_DIR}"
    echo "  Image:     ${DOCKER_NAMESPACE}/${IMAGE_NAME}:${VERSION}"

    cd "$SERVICE_DIR"

    # Build the image
    docker build \
        -t "${DOCKER_NAMESPACE}/${IMAGE_NAME}:${VERSION}" \
        .

    # Tag as latest if version is not 'latest'
    if [ "$VERSION" != "latest" ]; then
        docker tag "${DOCKER_NAMESPACE}/${IMAGE_NAME}:${VERSION}" \
                   "${DOCKER_NAMESPACE}/${IMAGE_NAME}:latest"
    fi

    echo -e "${GREEN}✓ Successfully built ${DOCKER_NAMESPACE}/${IMAGE_NAME}:${VERSION}${NC}"
    echo ""
done

# Return to project root
cd "$PROJECT_ROOT"

# Display all built images
echo -e "${YELLOW}Built images:${NC}"
for SERVICE in "${SERVICES[@]}"; do
    IMAGE_NAME="${PROJECT_NAME}-${SERVICE}"
    docker images | grep "${DOCKER_NAMESPACE}/${IMAGE_NAME}" | head -2
done

echo ""
echo -e "${GREEN}Build complete!${NC}"
echo ""
echo "To push images to Docker Hub:"
echo "  docker login"
for SERVICE in "${SERVICES[@]}"; do
    IMAGE_NAME="${PROJECT_NAME}-${SERVICE}"
    echo "  docker push ${DOCKER_NAMESPACE}/${IMAGE_NAME}:${VERSION}"
    if [ "$VERSION" != "latest" ]; then
        echo "  docker push ${DOCKER_NAMESPACE}/${IMAGE_NAME}:latest"
    fi
done

echo ""
echo "To test locally with docker-compose:"
echo "  docker-compose up -d"
