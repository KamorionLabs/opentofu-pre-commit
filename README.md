# OpenTofu Pre-commit Tools

Docker images with OpenTofu and infrastructure tools
for CI/CD pipelines, pre-commit hooks, and dev environments.

## Quick Start

```bash
docker pull kamorion/opentofu-pre-commit:latest

docker run --rm -v $(pwd):/workspace \
  kamorion/opentofu-pre-commit:latest tofu init

docker run --rm -v $(pwd):/workspace \
  kamorion/opentofu-pre-commit:latest \
  pre-commit run --all-files
```

Also on GHCR:
`ghcr.io/kamorionlabs/opentofu-pre-commit:latest`

## Image Variants

| Tag | Base | Cloud CLIs | Arch |
|-----|------|------------|------|
| `latest` | Ubuntu 24.04 | AWS v2 | amd64/arm64 |
| `alpine` | Alpine 3.21 | AWS v1 | amd64/arm64 |
| `slim` | Debian Slim | AWS v2 | amd64/arm64 |
| `azurelinux` | Azure Linux 3.0 | AWS v2 + Azure | amd64 |

## Included Tools

**IaC**: OpenTofu, TFLint, Terraform-docs, Checkov, Trivy

**Quality**: Pre-commit (pre-cached), Yamllint,
Markdownlint-cli2, Shellcheck, Shfmt, Typos

**Security**: Gitleaks, Trivy, Checkov

**System**: Git, Curl, JQ, Python3, Node.js

## CI/CD Integration

### GitHub Actions

```yaml
jobs:
  validate:
    runs-on: ubuntu-latest
    container:
      image: kamorion/opentofu-pre-commit:alpine
    steps:
      - uses: actions/checkout@v4
      - run: tofu init && tofu validate
      - run: checkov -d .
```

### Azure DevOps

```yaml
container: kamorion/opentofu-pre-commit:azurelinux

steps:
- script: tofu init && tofu validate
  displayName: 'Validate'
```

### GitLab CI

```yaml
image: kamorion/opentofu-pre-commit:alpine

validate:
  script:
    - tofu init && tofu validate
    - checkov -d .
```

## Building Locally

```bash
docker build -f Dockerfile \
  -t opentofu-pre-commit:ubuntu .
docker build -f Dockerfile.alpine \
  -t opentofu-pre-commit:alpine .
docker build -f Dockerfile.slim \
  -t opentofu-pre-commit:slim .
docker build -f Dockerfile.azurelinux \
  -t opentofu-pre-commit:azurelinux .

docker run --rm opentofu-pre-commit:ubuntu verify
```

## Dependency Management

Dependencies are automatically updated via
[Renovate](https://docs.renovatebot.com/):
Docker base images, tool versions, pip/npm packages,
pre-commit hooks, and GitHub Actions.

## License

[MIT](LICENSE)
