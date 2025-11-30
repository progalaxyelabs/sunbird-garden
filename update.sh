#!/bin/bash
# Sunbird Garden - Package Update Manager
# Update StoneScriptPHP, ngx-stonescriptphp-client, or any package individually

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API_DIR="$SCRIPT_DIR/api"
WWW_DIR="$SCRIPT_DIR/www"

# Print colored output
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Show usage
show_usage() {
    cat << EOF
Sunbird Garden - Package Update Manager

Usage: ./update.sh [OPTION] [PACKAGE]

OPTIONS:
  --all                    Update all packages (composer + npm)
  --php [PACKAGE]          Update PHP packages via Composer
  --npm [PACKAGE]          Update npm packages
  --stonescript            Update StoneScriptPHP framework (alias for --php progalaxyelabs/stonescriptphp)
  --ngx-client             Update ngx-stonescriptphp-client (alias for --npm @progalaxyelabs/ngx-stonescriptphp-client)
  --check                  Check for outdated packages without updating
  --rebuild                Rebuild Docker containers after update
  --help                   Show this help message

EXAMPLES:
  # Update StoneScriptPHP framework
  ./update.sh --stonescript

  # Update Angular client library
  ./update.sh --ngx-client

  # Update all packages
  ./update.sh --all

  # Update specific PHP package
  ./update.sh --php firebase/php-jwt

  # Update specific npm package
  ./update.sh --npm @angular/core

  # Check what's outdated
  ./update.sh --check

  # Update all and rebuild Docker containers
  ./update.sh --all --rebuild

EOF
}

# Check for outdated packages
check_outdated() {
    print_header "Checking Outdated Packages"

    if [ -d "$API_DIR" ]; then
        print_info "Checking PHP packages (Composer)..."
        cd "$API_DIR"
        if [ -f "composer.json" ]; then
            composer outdated --direct || true
        else
            print_warning "No composer.json found in api/"
        fi
        echo ""
    fi

    if [ -d "$WWW_DIR" ]; then
        print_info "Checking npm packages..."
        cd "$WWW_DIR"
        if [ -f "package.json" ]; then
            npm outdated || true
        else
            print_warning "No package.json found in www/"
        fi
        echo ""
    fi

    cd "$SCRIPT_DIR"
}

# Update PHP packages via Composer
update_php() {
    local package="$1"

    print_header "Updating PHP Packages"

    if [ ! -d "$API_DIR" ]; then
        print_error "API directory not found: $API_DIR"
        exit 1
    fi

    cd "$API_DIR"

    if [ ! -f "composer.json" ]; then
        print_error "composer.json not found in $API_DIR"
        exit 1
    fi

    if [ -z "$package" ]; then
        print_info "Updating all PHP packages..."
        composer update
    else
        print_info "Updating package: $package"
        composer update "$package"
    fi

    print_success "PHP packages updated successfully"
    cd "$SCRIPT_DIR"
}

# Update npm packages
update_npm() {
    local package="$1"

    print_header "Updating npm Packages"

    if [ ! -d "$WWW_DIR" ]; then
        print_error "WWW directory not found: $WWW_DIR"
        exit 1
    fi

    cd "$WWW_DIR"

    if [ ! -f "package.json" ]; then
        print_error "package.json not found in $WWW_DIR"
        exit 1
    fi

    if [ -z "$package" ]; then
        print_info "Updating all npm packages..."
        npm update
    else
        print_info "Updating package: $package"
        npm update "$package"
    fi

    print_success "npm packages updated successfully"
    cd "$SCRIPT_DIR"
}

# Update StoneScriptPHP framework
update_stonescript() {
    print_info "Updating StoneScriptPHP framework..."
    update_php "progalaxyelabs/stonescriptphp"
}

# Update ngx-stonescriptphp-client
update_ngx_client() {
    print_info "Updating ngx-stonescriptphp-client..."
    update_npm "@progalaxyelabs/ngx-stonescriptphp-client"
}

# Update all packages
update_all() {
    print_header "Updating All Packages"

    update_php
    echo ""
    update_npm

    print_success "All packages updated successfully"
}

# Rebuild Docker containers
rebuild_containers() {
    print_header "Rebuilding Docker Containers"

    if [ ! -f "$SCRIPT_DIR/docker-compose.yaml" ]; then
        print_warning "docker-compose.yaml not found, skipping rebuild"
        return
    fi

    print_info "Stopping containers..."
    docker compose down

    print_info "Rebuilding images..."
    docker compose build --no-cache

    print_info "Starting containers..."
    docker compose up -d

    print_success "Docker containers rebuilt and started"
}

# Main script logic
main() {
    if [ $# -eq 0 ]; then
        show_usage
        exit 0
    fi

    local rebuild=false

    while [ $# -gt 0 ]; do
        case "$1" in
            --help|-h)
                show_usage
                exit 0
                ;;
            --check)
                check_outdated
                exit 0
                ;;
            --all)
                update_all
                shift
                ;;
            --php)
                shift
                update_php "$1"
                shift
                ;;
            --npm)
                shift
                update_npm "$1"
                shift
                ;;
            --stonescript)
                update_stonescript
                shift
                ;;
            --ngx-client)
                update_ngx_client
                shift
                ;;
            --rebuild)
                rebuild=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                echo ""
                show_usage
                exit 1
                ;;
        esac
    done

    if [ "$rebuild" = true ]; then
        rebuild_containers
    fi

    print_header "Update Complete"
    print_success "Sunbird Garden packages are up to date!"
    print_info "Run './update.sh --check' to verify current versions"
}

# Run main function
main "$@"
