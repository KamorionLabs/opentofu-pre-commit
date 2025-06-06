#!/bin/bash
# Azure DevOps entrypoint script
set -e

echo "🚀 Azure DevOps OpenTofu Container Starting..."

# Fix permissions for Azure DevOps
if [ "$(id -u)" = "0" ]; then
    echo "🔧 Fixing permissions for Azure DevOps..."
    chown -R vsts_azpcontainer:docker_azpcontainer /opt/tofu/plugin-cache 2>/dev/null || true
    chmod -R 777 /opt/tofu/plugin-cache 2>/dev/null || true
fi

# Set up terraformrc for current user
if [ ! -f "$HOME/.terraformrc" ] && [ -f "/etc/skel/.terraformrc" ]; then
    cp /etc/skel/.terraformrc "$HOME/.terraformrc"
fi

echo "✅ Azure DevOps setup complete"

# Execute the command
exec "$@"
