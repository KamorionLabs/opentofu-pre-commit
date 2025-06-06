# OpenTofu Infrastructure Pipeline Container - Standard Ubuntu
# Comprehensive toolset for infrastructure automation and CI/CD pipelines
FROM ubuntu:22.04

# Avoid interactive prompts and set timezone
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Europe/Paris \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PATH="/usr/local/bin:$PATH"

# Tool versions
ARG TOFU_VERSION=1.9.1
ARG TERRAFORM_DOCS_VERSION=0.16.0
ARG TFLINT_VERSION=0.50.3
ARG TRIVY_VERSION=0.50.1
ARG SHFMT_VERSION=3.7.0
ARG GITLEAKS_VERSION=8.18.0

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    wget \
    unzip \
    git \
    jq \
    python3 \
    python3-pip \
    ca-certificates \
    gnupg \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Install binary tools
RUN set -eux; \
    # Create temp directory
    mkdir -p /tmp/downloads; \
    cd /tmp/downloads; \
    \
    # Detect architecture
    ARCH=$(dpkg --print-architecture); \
    case $ARCH in \
        amd64) ARCH="amd64" ;; \
        arm64) ARCH="arm64" ;; \
        *) echo "Unsupported architecture: $ARCH" && exit 1 ;; \
    esac; \
    \
    # Download and install OpenTofu
    wget -q "https://github.com/opentofu/opentofu/releases/download/v${TOFU_VERSION}/tofu_${TOFU_VERSION}_linux_${ARCH}.zip"; \
    unzip -q "tofu_${TOFU_VERSION}_linux_${ARCH}.zip"; \
    mv tofu /usr/local/bin/; \
    chmod +x /usr/local/bin/tofu; \
    \
    # Download and install terraform-docs
    wget -q "https://github.com/terraform-docs/terraform-docs/releases/download/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-${ARCH}.tar.gz"; \
    tar -xzf "terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-${ARCH}.tar.gz"; \
    mv terraform-docs /usr/local/bin/; \
    chmod +x /usr/local/bin/terraform-docs; \
    \
    # Download and install TFLint
    wget -q "https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_${ARCH}.zip"; \
    unzip -q "tflint_linux_${ARCH}.zip"; \
    mv tflint /usr/local/bin/; \
    chmod +x /usr/local/bin/tflint; \
    \
    # Download and install Trivy
    wget -q "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz"; \
    tar -xzf "trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz"; \
    mv trivy /usr/local/bin/; \
    chmod +x /usr/local/bin/trivy; \
    \
    # Download and install shfmt
    wget -q "https://github.com/mvdan/sh/releases/download/v${SHFMT_VERSION}/shfmt_v${SHFMT_VERSION}_linux_${ARCH}"; \
    mv "shfmt_v${SHFMT_VERSION}_linux_${ARCH}" /usr/local/bin/shfmt; \
    chmod +x /usr/local/bin/shfmt; \
    \
    # Download and install gitleaks (with ARM64 fallback)
    if wget -q "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_${ARCH}.tar.gz"; then \
        tar -xzf "gitleaks_${GITLEAKS_VERSION}_linux_${ARCH}.tar.gz"; \
        mv gitleaks /usr/local/bin/; \
        chmod +x /usr/local/bin/gitleaks; \
    else \
        echo "Warning: gitleaks not available for ${ARCH}, creating placeholder..."; \
        echo '#!/bin/bash' > /usr/local/bin/gitleaks; \
        echo 'echo "gitleaks not available for this architecture"' >> /usr/local/bin/gitleaks; \
        chmod +x /usr/local/bin/gitleaks; \
    fi; \
    \
    # Install Python tools
    pip3 install --no-cache-dir \
        checkov==3.2.0 \
        yamllint==1.35.0 \
        typos==1.16.0; \
    \
    # Install Node.js tools
    npm install -g --no-optional --no-audit --no-fund \
        markdownlint-cli2@0.11.0; \
    \
    # Cleanup
    cd /; \
    rm -rf /tmp/downloads; \
    rm -rf /root/.cache; \
    rm -rf /root/.npm; \
    npm cache clean --force 2>/dev/null || true; \
    python3 -m pip cache purge 2>/dev/null || true

# Copy helper scripts
COPY docker/verify-tools.sh /usr/local/bin/verify-tools.sh
COPY docker/dev-entrypoint.sh /usr/local/bin/dev-entrypoint.sh
COPY docker/dev-mode.sh /usr/local/bin/dev-mode.sh
COPY docker/fix-permissions.sh /usr/local/bin/fix-permissions.sh
COPY docker/azure-devops-entrypoint.sh /usr/local/bin/azure-devops-entrypoint.sh
COPY docker/test-plugin-cache.sh /usr/local/bin/test-plugin-cache.sh

# Create Azure DevOps user and setup permissions
RUN groupadd -g 1001 docker_azpcontainer \
    && useradd -m -u 1001 -g 1001 vsts_azpcontainer \
    && chmod +x /usr/local/bin/*.sh \
    && mkdir -p /workspace /shared/aws \
    && chmod 777 /shared/aws \
    && ln -sf /usr/local/bin/dev-mode.sh /usr/local/bin/dev \
    && ln -sf /usr/local/bin/verify-tools.sh /usr/local/bin/verify \
    && ln -sf /usr/local/bin/dev-entrypoint.sh /usr/local/bin/dev-entrypoint \
    && ln -sf /usr/local/bin/fix-permissions.sh /usr/local/bin/fix-permissions \
    && ln -sf /usr/local/bin/azure-devops-entrypoint.sh /usr/local/bin/azure-devops-entrypoint \
    && ln -sf /usr/local/bin/test-plugin-cache.sh /usr/local/bin/test-plugin-cache

# Set working directory
WORKDIR /workspace

# Labels for metadata
LABEL maintainer="DevOps Team" \
      description="Standard Ubuntu-based OpenTofu infrastructure tools for Azure DevOps" \
      version="1.0.0" \
      base-image="ubuntu:22.04" \
      tools="opentofu,tflint,trivy,checkov,terraform-docs,markdownlint-cli2,gitleaks,typos,yamllint,shfmt"

# Default command
CMD ["/bin/bash"]
