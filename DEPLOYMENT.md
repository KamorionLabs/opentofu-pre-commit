# 🚀 Deployment Guide

This guide explains how to set up automated builds and deployments to both Docker Hub and GitHub Container Registry.

## 📋 Prerequisites

1. **GitHub Repository**: Your project should be hosted on GitHub
2. **Docker Hub Account**: Create an account at [hub.docker.com](https://hub.docker.com)
3. **GitHub Personal Access Token**: For GHCR access

## 🔐 Setting up Secrets

### GitHub Repository Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions, and add these secrets:

#### Required Secrets

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `DOCKERHUB_USERNAME` | Your Docker Hub username (for login) | `clark42` |
| `DOCKERHUB_TOKEN` | Docker Hub access token | `dckr_pat_...` |

#### Required Variables

Go to your GitHub repository → Settings → Secrets and variables → Actions → Variables tab:

| Variable Name | Description | Example |
|---------------|-------------|---------|
| `DOCKERHUB_REPO` | Docker Hub repository/organization | `kamorion` |

#### Optional Secrets (Auto-configured)

| Secret Name | Description | Auto-configured |
|-------------|-------------|-----------------|
| `GITHUB_TOKEN` | GitHub token for GHCR | ✅ Automatically available |

### Creating Docker Hub Access Token

1. Log in to [Docker Hub](https://hub.docker.com)
2. Go to Account Settings → Security
3. Click "New Access Token"
4. Name: `GitHub Actions`
5. Permissions: `Read, Write, Delete`
6. Copy the generated token
7. Add it as `DOCKERHUB_TOKEN` secret in GitHub

## 🏗️ Automated Deployment

### GitHub Actions Workflow

The included `.github/workflows/docker-build.yml` automatically:

- **Triggers on**:
  - Push to `main` or `develop` branches
  - Pull requests to `main`
  - Weekly schedule (Sundays at 2 AM UTC)
  - Manual workflow dispatch

- **Builds and pushes to**:
  - 🐳 Docker Hub: `your-username/opentofu-pre-commit`
  - 📦 GitHub Container Registry: `ghcr.io/your-org/opentofu-pre-commit`

- **Image variants**:
  - `latest` / `ubuntu` (Ubuntu 22.04)
  - `alpine` (Alpine 3.19)
  - `slim` (Debian Bookworm Slim)

### Workflow Features

✅ **Multi-architecture builds** (AMD64 + ARM64)  
✅ **Automated testing** for each variant  
✅ **Security scanning** with Trivy  
✅ **Cache optimization** for faster builds  
✅ **Automatic README updates**  

## 🛠️ Manual Deployment

### Local Build and Push

Use the included script for local development:

```bash
# Set your credentials
export DOCKERHUB_USERNAME="your-dockerhub-username"
export GITHUB_USERNAME="your-github-username"

# Login to registries
docker login
echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USERNAME --password-stdin

# Build and push all variants
./build-and-push.sh
```

### Individual Builds

```bash
# Build specific variant
docker build -f Dockerfile.alpine -t your-username/opentofu-pre-commit:alpine .

# Push to Docker Hub
docker push your-username/opentofu-pre-commit:alpine

# Tag and push to GHCR
docker tag your-username/opentofu-pre-commit:alpine ghcr.io/your-org/opentofu-pre-commit:alpine
docker push ghcr.io/your-org/opentofu-pre-commit:alpine
```

## 📊 Registry Comparison

| Feature | Docker Hub | GitHub Container Registry |
|---------|------------|---------------------------|
| **Public Access** | ✅ Free | ✅ Free |
| **Private Repos** | 1 free, then paid | ✅ Free for public repos |
| **Pull Rate Limits** | 200/6h anonymous, 5000/6h authenticated | Higher limits |
| **Integration** | Universal | GitHub ecosystem |
| **Bandwidth** | Global CDN | Global CDN |
| **Best for** | Public distribution | GitHub-integrated projects |

## 🔄 Deployment Strategies

### Production Deployment

**Recommended approach:**

1. **Development**: Use `develop` branch for testing
2. **Staging**: Use `main` branch for staging builds
3. **Production**: Use Git tags for production releases

```bash
# Create a production release
git tag v1.0.0
git push origin v1.0.0
```

This creates versioned images:
- `your-username/opentofu-pre-commit:v1.0.0`
- `your-username/opentofu-pre-commit:v1.0`
- `your-username/opentofu-pre-commit:v1`

### Branch-based Deployment

| Branch | Docker Tags | Use Case |
|--------|-------------|----------|
| `main` | `latest`, `ubuntu`, `alpine`, `slim` | Stable releases |
| `develop` | `develop`, `develop-alpine`, `develop-slim` | Development testing |
| `feature/*` | Not deployed | Feature development |

## 🔍 Monitoring Deployments

### GitHub Actions

Monitor builds at: `https://github.com/your-org/opentofu-pre-commit/actions`

### Docker Hub

Monitor images at: `https://hub.docker.com/r/your-username/opentofu-pre-commit`

### GitHub Container Registry

Monitor packages at: `https://github.com/your-org/opentofu-pre-commit/pkgs/container/opentofu-pre-commit`

## 🚨 Troubleshooting

### Common Issues

#### Authentication Errors

```bash
# Docker Hub login failed
Error: denied: requested access to the resource is denied
```

**Solution**: Check `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` secrets

#### GHCR Permission Denied

```bash
# GHCR push failed
Error: denied: permission_denied
```

**Solution**: Ensure `packages: write` permission in workflow

#### Build Failures

```bash
# Multi-arch build failed
Error: failed to solve: process "/bin/sh -c ..." did not complete successfully
```

**Solution**: Check Dockerfile syntax and platform-specific commands

### Debug Commands

```bash
# Test local build
docker build -f Dockerfile.slim -t test:slim .

# Test tools in container
docker run --rm test:slim verify-tools.sh

# Check image size
docker images | grep opentofu-pre-commit

# Inspect image layers
docker history your-username/opentofu-pre-commit:alpine
```

## 📈 Optimization Tips

### Build Performance

1. **Use BuildKit cache**: Enabled by default in workflow
2. **Optimize layer order**: Put frequently changing commands last
3. **Multi-stage builds**: Already implemented for size optimization

### Registry Performance

1. **Use appropriate variant**:
   - Alpine for CI/CD (smallest)
   - Ubuntu for development (most compatible)
   - Slim for balanced use cases

2. **Pin specific versions** in production:
   ```bash
   # Instead of
   docker pull your-username/opentofu-pre-commit:latest
   
   # Use
   docker pull your-username/opentofu-pre-commit:v1.0.0-alpine
   ```

## 🔒 Security Best Practices

### Secrets Management

- ✅ Use GitHub Secrets for sensitive data
- ✅ Rotate Docker Hub tokens regularly
- ✅ Use least-privilege access tokens
- ❌ Never commit secrets to repository

### Image Security

- ✅ Automated vulnerability scanning with Trivy
- ✅ Regular base image updates
- ✅ Minimal attack surface
- ✅ Non-root user execution

### Supply Chain Security

- ✅ Pinned tool versions
- ✅ Checksum verification
- ✅ Signed commits (recommended)
- ✅ Dependabot updates

## 📞 Support

If you encounter issues:

1. Check the [troubleshooting section](#-troubleshooting)
2. Review [GitHub Actions logs](https://github.com/your-org/opentofu-pre-commit/actions)
3. Open an [issue](https://github.com/your-org/opentofu-pre-commit/issues)

---

**Happy deploying! 🚀**
