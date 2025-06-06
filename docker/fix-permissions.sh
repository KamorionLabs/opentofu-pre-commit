#!/bin/bash
# Fix permissions for Azure DevOps and other CI/CD systems
set -e

echo "🔧 Fixing permissions..."

# Fix plugin cache permissions
if [ -d "/opt/tofu/plugin-cache" ]; then
    chmod -R 777 /opt/tofu/plugin-cache
    echo "✅ Plugin cache permissions fixed"
fi

# Fix workspace permissions
if [ -d "/workspace" ]; then
    chmod -R 777 /workspace
    echo "✅ Workspace permissions fixed"
fi

# Fix shared directory permissions
if [ -d "/shared" ]; then
    chmod -R 777 /shared
    echo "✅ Shared directory permissions fixed"
fi

echo "🎉 Permissions fix completed!"
