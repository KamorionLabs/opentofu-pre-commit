#!/bin/bash
# Pre-commit helper script for OpenTofu projects
# This script helps initialize and run pre-commit hooks in the container

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to show usage
show_usage() {
    echo -e "${BLUE}=== Pre-commit Helper for OpenTofu Projects ===${NC}"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  install     Install pre-commit hooks in the current repository"
    echo "  run         Run pre-commit on all files"
    echo "  run-staged  Run pre-commit on staged files only"
    echo "  update      Update pre-commit hooks to latest versions"
    echo "  clean       Clean pre-commit cache"
    echo "  validate    Validate .pre-commit-config.yaml"
    echo "  help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 install     # Install hooks in current repo"
    echo "  $0 run         # Run all hooks on all files"
    echo "  $0 run-staged  # Run hooks on staged files"
    echo ""
}

# Function to check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not in a git repository. Please run this command from within a git repository."
        exit 1
    fi
}

# Function to check if .pre-commit-config.yaml exists
check_precommit_config() {
    if [ ! -f ".pre-commit-config.yaml" ]; then
        print_warning "No .pre-commit-config.yaml found in current directory."
        print_info "You can copy the example configuration from the container:"
        print_info "  cp /workspace/.pre-commit-config.yaml ."
        return 1
    fi
    return 0
}

# Function to install pre-commit hooks
install_hooks() {
    print_info "Installing pre-commit hooks..."
    check_git_repo
    
    if ! check_precommit_config; then
        exit 1
    fi
    
    if pre-commit install; then
        print_success "Pre-commit hooks installed successfully!"
        print_info "Hooks will now run automatically on git commit."
    else
        print_error "Failed to install pre-commit hooks."
        exit 1
    fi
}

# Function to run pre-commit on all files
run_all() {
    print_info "Running pre-commit on all files..."
    check_git_repo
    
    if ! check_precommit_config; then
        exit 1
    fi
    
    if pre-commit run --all-files; then
        print_success "All pre-commit checks passed!"
    else
        print_warning "Some pre-commit checks failed. Please review and fix the issues above."
        exit 1
    fi
}

# Function to run pre-commit on staged files
run_staged() {
    print_info "Running pre-commit on staged files..."
    check_git_repo
    
    if ! check_precommit_config; then
        exit 1
    fi
    
    if pre-commit run; then
        print_success "All pre-commit checks passed on staged files!"
    else
        print_warning "Some pre-commit checks failed. Please review and fix the issues above."
        exit 1
    fi
}

# Function to update pre-commit hooks
update_hooks() {
    print_info "Updating pre-commit hooks..."
    check_git_repo
    
    if ! check_precommit_config; then
        exit 1
    fi
    
    if pre-commit autoupdate; then
        print_success "Pre-commit hooks updated successfully!"
    else
        print_error "Failed to update pre-commit hooks."
        exit 1
    fi
}

# Function to clean pre-commit cache
clean_cache() {
    print_info "Cleaning pre-commit cache..."
    
    if pre-commit clean; then
        print_success "Pre-commit cache cleaned successfully!"
    else
        print_error "Failed to clean pre-commit cache."
        exit 1
    fi
}

# Function to validate pre-commit config
validate_config() {
    print_info "Validating .pre-commit-config.yaml..."
    
    if ! check_precommit_config; then
        exit 1
    fi
    
    if pre-commit validate-config; then
        print_success "Pre-commit configuration is valid!"
    else
        print_error "Pre-commit configuration is invalid."
        exit 1
    fi
}

# Main script logic
case "${1:-help}" in
    install)
        install_hooks
        ;;
    run)
        run_all
        ;;
    run-staged)
        run_staged
        ;;
    update)
        update_hooks
        ;;
    clean)
        clean_cache
        ;;
    validate)
        validate_config
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_usage
        exit 1
        ;;
esac
