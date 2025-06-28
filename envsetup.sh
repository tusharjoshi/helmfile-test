#!/bin/bash

# Helmfile Setup Script
# This script installs helmfile and helm for use with the project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_color $BLUE "Setting up Helmfile development environment..."

# Detect OS
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case $ARCH in
    x86_64) ARCH="amd64" ;;
    arm64|aarch64) ARCH="arm64" ;;
    *) print_color $RED "Unsupported architecture: $ARCH"; exit 1 ;;
esac

# Install Helm if not present
if ! command -v helm &> /dev/null; then
    print_color $YELLOW "Installing Helm..."
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
    rm get_helm.sh
    print_color $GREEN "Helm installed successfully!"
else
    print_color $GREEN "Helm is already installed: $(helm version --short)"
fi

# Install Helmfile if not present
if ! command -v helmfile &> /dev/null; then
    print_color $YELLOW "Installing Helmfile..."
    
    # Use the new helmfile repository URL
    HELMFILE_VERSION="v0.162.0"
    HELMFILE_URL="https://github.com/helmfile/helmfile/releases/download/${HELMFILE_VERSION}/helmfile_${OS}_${ARCH}.tar.gz"
    
    print_color $BLUE "Downloading from: $HELMFILE_URL"
    
    # Download and extract
    curl -LO "$HELMFILE_URL"
    tar -xzf "helmfile_${OS}_${ARCH}.tar.gz"
    chmod +x helmfile
    
    # Move to PATH
    if [[ "$OS" == "darwin" ]]; then
        # macOS
        sudo mv helmfile /usr/local/bin/
    else
        # Linux
        sudo mv helmfile /usr/local/bin/
    fi
    
    # Cleanup
    rm -f "helmfile_${OS}_${ARCH}.tar.gz"
    
    print_color $GREEN "Helmfile installed successfully!"
else
    print_color $GREEN "Helmfile is already installed: $(helmfile version)"
fi

# Add helm repositories
print_color $YELLOW "Adding Helm repositories..."
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

print_color $GREEN "Setup complete!"
print_color $BLUE "You can now use the following commands:"
echo "  ./deploy.sh deploy development    # Deploy to development"
echo "  ./deploy.sh status development    # Check deployment status"
echo "  ./deploy.sh destroy development   # Clean up deployment"
