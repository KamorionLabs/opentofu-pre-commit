#!/bin/bash
# Preload essential OpenTofu providers for faster initialization
set -e

echo "🔄 Preloading essential OpenTofu providers..."

# Create a temporary directory for provider preloading
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Create a minimal configuration to download providers
cat > main.tf << 'EOF'
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# Minimal provider configurations
provider "aws" {
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  region                      = "us-east-1"
}

provider "random" {}
provider "null" {}
provider "local" {}
provider "tls" {}
EOF

# Initialize to download providers
echo "📦 Downloading providers..."
tofu init

# Verify cache was populated
if [ -d "/opt/tofu/plugin-cache" ]; then
    CACHED_FILES=$(find /opt/tofu/plugin-cache -type f | wc -l)
    echo "✅ Provider cache populated with $CACHED_FILES files"
else
    echo "⚠️ Provider cache directory not found"
fi

# Cleanup
cd /
rm -rf "$TEMP_DIR"

echo "🎉 Provider preloading completed!"
