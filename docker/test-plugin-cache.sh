#!/bin/bash
# Test OpenTofu plugin cache functionality
set -e

echo "🧪 Testing OpenTofu plugin cache..."

# Check if cache directory exists
if [ ! -d "/opt/tofu/plugin-cache" ]; then
    echo "❌ Plugin cache directory not found"
    exit 1
fi

# Check cache contents
CACHE_FILES=$(find /opt/tofu/plugin-cache -type f 2>/dev/null | wc -l)
echo "📦 Found $CACHE_FILES cached files"

if [ "$CACHE_FILES" -eq 0 ]; then
    echo "⚠️ Plugin cache is empty"
    exit 1
fi

# Test with a simple configuration
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

cat > test.tf << 'EOF'
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  region                      = "us-east-1"
}
EOF

echo "🔄 Testing provider initialization..."
if tofu init >/dev/null 2>&1; then
    echo "✅ Plugin cache working correctly"
else
    echo "❌ Plugin cache test failed"
    cd /
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Cleanup
cd /
rm -rf "$TEMP_DIR"

echo "🎉 Plugin cache test completed successfully!"
