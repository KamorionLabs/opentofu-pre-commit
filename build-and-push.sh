#!/bin/bash
# Build and push script for local development
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOCKERHUB_USERNAME="${DOCKERHUB_USERNAME:-your-dockerhub-username}"
DOCKERHUB_REPO="${DOCKERHUB_REPO:-your-dockerhub-repo}"
GITHUB_USERNAME="${GITHUB_USERNAME:-your-github-username}"
REPO_NAME="${REPO_NAME:-opentofu-pre-commit}"

# Image names
DOCKERHUB_IMAGE="${DOCKERHUB_REPO}/${REPO_NAME}"
GHCR_IMAGE="ghcr.io/${GITHUB_USERNAME}/${REPO_NAME}"

echo -e "${BLUE}=== OpenTofu Pre-commit Images Build & Push ===${NC}"
echo ""

# Function to build and push an image variant
build_and_push() {
    local variant="$1"
    local dockerfile="$2"
    local tag_suffix="$3"
    
    echo -e "${YELLOW}Building and pushing ${variant} variant...${NC}"
    
    # Determine tags
    local dockerhub_tag="${DOCKERHUB_IMAGE}:${tag_suffix}"
    local ghcr_tag="${GHCR_IMAGE}:${tag_suffix}"
    
    if [ "$variant" = "ubuntu" ]; then
        dockerhub_tag="${DOCKERHUB_IMAGE}:latest"
        ghcr_tag="${GHCR_IMAGE}:latest"
    fi
    
    echo "Building image..."
    docker build -f "$dockerfile" -t "$dockerhub_tag" -t "$ghcr_tag" .
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Build successful${NC}"
        
        echo "Pushing to Docker Hub..."
        docker push "$dockerhub_tag"
        
        echo "Pushing to GitHub Container Registry..."
        docker push "$ghcr_tag"
        
        # Also push variant-specific tag for ubuntu
        if [ "$variant" = "ubuntu" ]; then
            docker tag "$dockerhub_tag" "${DOCKERHUB_IMAGE}:ubuntu"
            docker tag "$ghcr_tag" "${GHCR_IMAGE}:ubuntu"
            docker push "${DOCKERHUB_IMAGE}:ubuntu"
            docker push "${GHCR_IMAGE}:ubuntu"
        fi
        
        echo -e "${GREEN}✅ Push successful${NC}"
    else
        echo -e "${RED}❌ Build failed${NC}"
        return 1
    fi
    
    echo ""
}

# Check if logged in to registries
echo "Checking Docker registry authentication..."

if ! docker info | grep -q "Username"; then
    echo -e "${YELLOW}⚠️ Please login to Docker Hub first:${NC}"
    echo "docker login"
    exit 1
fi

if ! docker info | grep -q "ghcr.io"; then
    echo -e "${YELLOW}⚠️ Please login to GitHub Container Registry first:${NC}"
    echo "echo \$GITHUB_TOKEN | docker login ghcr.io -u \$GITHUB_USERNAME --password-stdin"
fi

echo -e "${GREEN}✅ Registry authentication OK${NC}"
echo ""

# Build and push all variants
build_and_push "ubuntu" "Dockerfile" "latest"
build_and_push "alpine" "Dockerfile.alpine" "alpine"
build_and_push "slim" "Dockerfile.slim" "slim"

echo -e "${BLUE}=== Build & Push Summary ===${NC}"
echo -e "${GREEN}🎉 All images built and pushed successfully!${NC}"
echo ""
echo "Available on Docker Hub:"
echo "- ${DOCKERHUB_IMAGE}:latest"
echo "- ${DOCKERHUB_IMAGE}:ubuntu"
echo "- ${DOCKERHUB_IMAGE}:alpine"
echo "- ${DOCKERHUB_IMAGE}:slim"
echo ""
echo "Available on GitHub Container Registry:"
echo "- ${GHCR_IMAGE}:latest"
echo "- ${GHCR_IMAGE}:ubuntu"
echo "- ${GHCR_IMAGE}:alpine"
echo "- ${GHCR_IMAGE}:slim"
