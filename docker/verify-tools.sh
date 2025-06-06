#!/bin/bash
# Verify all tools are installed and working correctly
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== OpenTofu Infrastructure Tools Verification ===${NC}"
echo ""

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to test a tool
test_tool() {
  local tool_name="$1"
  local test_command="$2"

  echo -n "Testing $tool_name... "
  if eval "$test_command" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ OK${NC}"
    ((TESTS_PASSED++))
  else
    echo -e "${RED}❌ FAILED${NC}"
    ((TESTS_FAILED++))
  fi
}

# Test core tools
echo -e "${YELLOW}Core Infrastructure Tools:${NC}"
test_tool "OpenTofu" "tofu version"
test_tool "TFLint" "tflint --version"
test_tool "Trivy" "trivy --version"
test_tool "Terraform-docs" "terraform-docs --version"
test_tool "Shfmt" "shfmt --version"

echo ""
echo -e "${YELLOW}Security Tools:${NC}"
test_tool "Gitleaks" "gitleaks version"

echo ""
echo -e "${YELLOW}Python Tools:${NC}"
test_tool "Pre-commit" "pre-commit --version"
test_tool "Checkov" "checkov --version"
test_tool "Yamllint" "yamllint --version"
test_tool "Typos" "typos --version"

echo ""
echo -e "${YELLOW}Node.js Tools:${NC}"
test_tool "Markdownlint" "markdownlint-cli2 --version"

echo ""
echo -e "${YELLOW}System Tools:${NC}"
test_tool "Git" "git --version"
test_tool "Curl" "curl --version"
test_tool "JQ" "jq --version"
test_tool "Python3" "python3 --version"
test_tool "Node.js" "node --version"
test_tool "NPM" "npm --version"

echo ""
echo -e "${BLUE}=== Verification Summary ===${NC}"
echo -e "${GREEN}✅ Tests passed: $TESTS_PASSED${NC}"
echo -e "${RED}❌ Tests failed: $TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
  echo -e "${GREEN}🎉 All tools are working correctly!${NC}"
  exit 0
else
  echo -e "${RED}⚠️ Some tools failed verification.${NC}"
  exit 1
fi
