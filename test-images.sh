#!/bin/bash
# Test script for all Docker image variants
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== OpenTofu Pre-commit Images Test Suite ===${NC}"
echo ""

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to test an image variant
test_image() {
    local variant="$1"
    local dockerfile="$2"
    local tag="opentofu-pre-commit:${variant}"
    
    echo -e "${YELLOW}Testing ${variant} variant...${NC}"
    
    # Build the image
    echo "Building ${variant} image..."
    if docker build -f "$dockerfile" -t "$tag" . >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Build successful${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ Build failed${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
    
    # Test tools verification
    echo "Testing tools verification..."
    if docker run --rm "$tag" verify-tools.sh >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Tools verification passed${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ Tools verification failed${NC}"
        ((TESTS_FAILED++))
    fi
    
    # Test plugin cache
    echo "Testing plugin cache..."
    if docker run --rm "$tag" test-plugin-cache.sh >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Plugin cache test passed${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ Plugin cache test failed${NC}"
        ((TESTS_FAILED++))
    fi
    
    # Test basic OpenTofu functionality
    echo "Testing OpenTofu functionality..."
    if docker run --rm "$tag" tofu version >/dev/null 2>&1; then
        echo -e "${GREEN}✅ OpenTofu test passed${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ OpenTofu test failed${NC}"
        ((TESTS_FAILED++))
    fi
    
    echo ""
}

# Test all variants
test_image "ubuntu" "Dockerfile"
test_image "alpine" "Dockerfile.alpine"
test_image "slim" "Dockerfile.slim"

# Summary
echo -e "${BLUE}=== Test Summary ===${NC}"
echo -e "${GREEN}✅ Tests passed: $TESTS_PASSED${NC}"
echo -e "${RED}❌ Tests failed: $TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}⚠️ Some tests failed.${NC}"
    exit 1
fi
