# OpenTofu Pre-commit Tools

Comprehensive Docker images with OpenTofu and infrastructure tools for
CI/CD pipelines, pre-commit hooks, and development environments.

## Quick Start

```bash
# Pull from Docker Hub (recommended)
docker pull kamorion/opentofu-pre-commit:latest

# Or pull from GitHub Container Registry
docker pull ghcr.io/kamorionlabs/opentofu-pre-commit:latest

# Basic usage with your infrastructure code
docker run --rm -v $(pwd):/workspace \
  kamorion/opentofu-pre-commit:latest tofu version

# With AWS credentials for real infrastructure work
docker run --rm \
  -v $(pwd):/workspace \
  -v ~/.aws:/shared/aws:ro \
  kamorion/opentofu-pre-commit:latest tofu plan

# Run pre-commit hooks on your current directory
docker run --rm \
  -v $(pwd):/workspace \
  -v ~/.aws:/shared/aws:ro \
  kamorion/opentofu-pre-commit:latest pre-commit run --all-files
```

## Available Images

We provide four optimized variants:

### Ubuntu (Default)

- **Tag**: `latest`, `ubuntu`
- **Base**: Ubuntu 24.04
- **Best for**: Full compatibility, development environments
- **Cloud CLIs**: AWS CLI v2, Azure CLI

```bash
docker pull kamorion/opentofu-pre-commit:latest
```

### Alpine

- **Tag**: `alpine`
- **Base**: Alpine 3.21
- **Best for**: Minimal footprint, AWS-only pipelines
- **Cloud CLIs**: AWS CLI (no Azure CLI)

```bash
docker pull kamorion/opentofu-pre-commit:alpine
```

### Slim

- **Tag**: `slim`
- **Base**: Debian Bookworm Slim
- **Best for**: Balance between size and compatibility
- **Cloud CLIs**: AWS CLI v2, Azure CLI

```bash
docker pull kamorion/opentofu-pre-commit:slim
```

### Azure Linux

- **Tag**: `azurelinux`
- **Base**: Azure Linux 3.0 (from `mcr.microsoft.com/azure-cli`)
- **Best for**: Azure DevOps pipelines, native Azure CLI support
- **Cloud CLIs**: AWS CLI v2, Azure CLI (maintained by Microsoft)

```bash
docker pull kamorion/opentofu-pre-commit:azurelinux
```

## Included Tools

### Core Infrastructure Tools

| Tool | Version | Description |
|------|---------|-------------|
| OpenTofu | v1.11.5 | Infrastructure as Code |
| TFLint | v0.61.0 | Terraform/OpenTofu linter |
| Trivy | v0.69.3 | Security scanner |
| Terraform-docs | v0.21.0 | Documentation generator |
| Shfmt | v3.12.0 | Shell script formatter |

### Security & Quality Tools

| Tool | Version | Description |
|------|---------|-------------|
| Pre-commit | v4.5.1 | Git hooks framework (with pre-cached hooks) |
| Checkov | v3.2.508 | Infrastructure security scanner |
| Gitleaks | v8.30.0 | Secret detection |
| Yamllint | v1.38.0 | YAML linter |
| Typos | v1.16.0 | Spell checker |
| Markdownlint-cli2 | v0.21.0 | Markdown linter |
| Shellcheck | v0.11.0 | Shell script analyzer |

### Cloud CLIs

| Tool | Ubuntu | Slim | Alpine | Azure Linux |
|------|--------|------|--------|-------------|
| AWS CLI v2 | Yes | Yes | Yes (v1) | Yes |
| Azure CLI | Yes | Yes | No | Yes (native) |

### System Tools

Git, Curl, JQ, Python3, Node.js, NPM

## Usage Examples

### Basic OpenTofu Commands

```bash
# Initialize OpenTofu
docker run --rm -v $(pwd):/workspace \
  kamorion/opentofu-pre-commit:latest tofu init

# Plan infrastructure changes
docker run --rm \
  -v $(pwd):/workspace \
  -v ~/.aws:/shared/aws:ro \
  kamorion/opentofu-pre-commit:latest tofu plan

# Apply changes
docker run --rm \
  -v $(pwd):/workspace \
  -v ~/.aws:/shared/aws:ro \
  kamorion/opentofu-pre-commit:latest tofu apply
```

### Security Scanning

```bash
# Scan infrastructure code with Checkov
docker run --rm -v $(pwd):/workspace \
  kamorion/opentofu-pre-commit:latest checkov -d .

# Scan for secrets with Gitleaks
docker run --rm -v $(pwd):/workspace \
  kamorion/opentofu-pre-commit:latest gitleaks detect --source .

# Security scan with Trivy
docker run --rm -v $(pwd):/workspace \
  kamorion/opentofu-pre-commit:latest trivy fs .
```

### Code Quality

```bash
# Lint OpenTofu files
docker run --rm -v $(pwd):/workspace \
  kamorion/opentofu-pre-commit:latest tflint

# Format shell scripts
docker run --rm -v $(pwd):/workspace \
  kamorion/opentofu-pre-commit:latest shfmt -w .

# Generate documentation
docker run --rm -v $(pwd):/workspace \
  kamorion/opentofu-pre-commit:latest terraform-docs .
```

### Pre-commit Integration

```bash
# Use the built-in pre-commit helper
docker run --rm -v $(pwd):/workspace \
  kamorion/opentofu-pre-commit:latest pre-commit-helper help

# Install pre-commit hooks in your project
docker run --rm -v $(pwd):/workspace \
  kamorion/opentofu-pre-commit:latest pre-commit-helper install

# Run pre-commit on all files
docker run --rm -v $(pwd):/workspace \
  kamorion/opentofu-pre-commit:latest pre-commit-helper run

# Run pre-commit on staged files only
docker run --rm -v $(pwd):/workspace \
  kamorion/opentofu-pre-commit:latest pre-commit-helper run-staged

# Update pre-commit hooks
docker run --rm -v $(pwd):/workspace \
  kamorion/opentofu-pre-commit:latest pre-commit-helper update

# Validate pre-commit configuration
docker run --rm -v $(pwd):/workspace \
  kamorion/opentofu-pre-commit:latest pre-commit-helper validate
```

### Development Mode

```bash
# Interactive development environment
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.aws:/shared/aws:ro \
  kamorion/opentofu-pre-commit:latest dev

# Verify all tools
docker run --rm kamorion/opentofu-pre-commit:latest verify
```

## CI/CD Integration

### GitHub Actions

```yaml
name: Infrastructure CI
on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    container:
      image: kamorion/opentofu-pre-commit:alpine
    steps:
      - uses: actions/checkout@v4
      - name: Validate OpenTofu
        run: |
          tofu init
          tofu validate
          tofu plan
      - name: Security scan
        run: |
          checkov -d .
          trivy fs .
```

### Azure DevOps

```yaml
pool:
  vmImage: 'ubuntu-latest'

container: kamorion/opentofu-pre-commit:azurelinux

steps:
- script: |
    tofu init
    tofu validate
    tofu plan
  displayName: 'OpenTofu Validation'

- script: |
    checkov -d .
    trivy fs .
  displayName: 'Security Scan'
```

### GitLab CI

```yaml
image: kamorion/opentofu-pre-commit:alpine

stages:
  - validate
  - security

validate:
  stage: validate
  script:
    - tofu init
    - tofu validate
    - tofu plan

security:
  stage: security
  script:
    - checkov -d .
    - trivy fs .
```

## Pre-commit Hooks

Create `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: local
    hooks:
      - id: tofu-fmt
        name: OpenTofu Format
        entry: docker run --rm -v $(pwd):/workspace \
          kamorion/opentofu-pre-commit:alpine tofu fmt
        language: system
        files: \.tf$

      - id: tofu-validate
        name: OpenTofu Validate
        entry: docker run --rm -v $(pwd):/workspace \
          -v ~/.aws:/shared/aws:ro \
          kamorion/opentofu-pre-commit:alpine sh -c \
          "tofu init && tofu validate"
        language: system
        files: \.tf$

      - id: tflint
        name: TFLint
        entry: docker run --rm -v $(pwd):/workspace \
          kamorion/opentofu-pre-commit:alpine tflint
        language: system
        files: \.tf$

      - id: checkov
        name: Checkov Security Scan
        entry: docker run --rm -v $(pwd):/workspace \
          kamorion/opentofu-pre-commit:alpine checkov -d .
        language: system
        files: \.tf$
```

## Customization

### Environment Variables

```bash
# Set custom plugin cache directory
docker run --rm -e TF_PLUGIN_CACHE_DIR=/custom/cache \
  kamorion/opentofu-pre-commit:latest

# Disable OpenTofu checkpoint
docker run --rm -e CHECKPOINT_DISABLE=1 \
  kamorion/opentofu-pre-commit:latest
```

### Volume Mounts

```bash
# Mount AWS credentials (recommended way)
docker run --rm \
  -v ~/.aws:/shared/aws:ro \
  -v $(pwd):/workspace \
  kamorion/opentofu-pre-commit:latest

# Mount SSH keys for Git
docker run --rm \
  -v ~/.ssh:/root/.ssh:ro \
  -v $(pwd):/workspace \
  kamorion/opentofu-pre-commit:latest
```

## Image Comparison

| Feature | Ubuntu | Alpine | Slim | Azure Linux |
|---------|--------|--------|------|-------------|
| Base OS | Ubuntu 24.04 | Alpine 3.21 | Debian Bookworm | Azure Linux 3.0 |
| glibc | Yes | No (musl) | Yes | Yes |
| Package Manager | apt | apk | apt | tdnf |
| AWS CLI | v2 | v1 (apk) | v2 | v2 |
| Azure CLI | Yes | No | Yes | Yes (native) |
| Provider Cache | No | Yes | Yes | No |
| Compatibility | Highest | Good | High | High |
| Best For | Dev env | Minimal CI | Balanced | Azure DevOps |

## Dependency Management

This project uses [Renovate](https://docs.renovatebot.com/) for automated
dependency updates. Renovate manages:

- Docker base image versions
- Binary tool versions (via ARG in Dockerfiles)
- Python package versions (pip)
- Node.js package versions (npm)
- Pre-commit hook versions
- GitHub Actions versions

To enable Renovate, install the
[Renovate GitHub App](https://github.com/apps/renovate) on the repository.

## Architecture

### Multi-stage Builds

Alpine and Slim images use multi-stage builds for optimal size and security:

1. **Base Stage**: Install system dependencies
2. **Tools Stage**: Download and install binary tools
3. **Providers Stage**: Pre-cache OpenTofu providers
4. **Final Stage**: Copy only necessary files

### Provider Caching (Alpine & Slim)

Images include pre-cached OpenTofu providers for faster initialization:

- AWS Provider ~5.0
- Random Provider ~3.1
- Null Provider ~3.1
- Local Provider ~2.1
- TLS Provider ~4.0

### Azure DevOps Compatibility

Special user and permission setup for Azure DevOps agents:

- User: `vsts_azpcontainer` (UID: 1001)
- Group: `docker_azpcontainer` (GID: 1001)
- Proper permissions for plugin cache and workspace

## Security

### Vulnerability Scanning

All images are automatically scanned with Trivy for vulnerabilities.

### Minimal Attack Surface

- No unnecessary packages
- Non-root user support
- Stripped binaries where possible
- Regular base image updates via Renovate

### Supply Chain Security

- Pinned tool versions
- Multi-stage builds
- Minimal final layer

## Building Locally

```bash
# Build Ubuntu variant
docker build -f Dockerfile -t opentofu-pre-commit:ubuntu .

# Build Alpine variant
docker build -f Dockerfile.alpine -t opentofu-pre-commit:alpine .

# Build Slim variant
docker build -f Dockerfile.slim -t opentofu-pre-commit:slim .

# Build Azure Linux variant
docker build -f Dockerfile.azurelinux -t opentofu-pre-commit:azurelinux .
```

### Testing

```bash
# Test tools installation
docker run --rm opentofu-pre-commit:ubuntu verify

# Test plugin cache (alpine/slim only)
docker run --rm opentofu-pre-commit:slim test-plugin-cache
```

## Tags and Versions

### Latest Tags

- `latest` - Ubuntu-based image (default)
- `ubuntu` - Ubuntu 24.04 based
- `alpine` - Alpine 3.21 based
- `slim` - Debian Bookworm Slim based
- `azurelinux` - Azure Linux 3.0 based

### Version Tags

- `v3.0.0`, `v3.0` - Semantic versioning
- `v3.0.0-alpine`, `v3.0.0-slim`, `v3.0.0-azurelinux` - Variant-specific versions

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with all image variants
5. Submit a pull request

## Support

- [Documentation](https://github.com/kamorionlabs/opentofu-pre-commit/wiki)
- [Issue Tracker](https://github.com/kamorionlabs/opentofu-pre-commit/issues)
- [Discussions](https://github.com/kamorionlabs/opentofu-pre-commit/discussions)

## License

This project is licensed under the MIT License - see the
[LICENSE](LICENSE) file for details.

Last updated: 2025-01-06 16:09:15 UTC
