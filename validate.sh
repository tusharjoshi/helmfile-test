#!/bin/bash

# Helmfile Validation Script
# This script validates the helmfile configuration and templates

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

print_color $BLUE "Validating Helmfile configuration..."

# Check if helmfile is installed
if ! command -v helmfile &> /dev/null; then
    print_color $RED "Error: helmfile is not installed"
    print_color $YELLOW "Please run ./envsetup.sh to install helmfile"
    exit 1
fi

# Check if helm is installed
if ! command -v helm &> /dev/null; then
    print_color $RED "Error: helm is not installed"
    print_color $YELLOW "Please run ./envsetup.sh to install helm"
    exit 1
fi

# Validate each environment
environments=("default" "development" "staging" "production")

for env in "${environments[@]}"; do
    print_color $YELLOW "Validating environment: $env"
    
    # Check if environment file exists
    if [[ ! -f "environments/${env}.yaml" ]]; then
        print_color $RED "Error: Environment file environments/${env}.yaml not found"
        exit 1
    fi
    
    # Validate helmfile template generation
    if helmfile --environment "$env" template --skip-deps > /dev/null 2>&1; then
        print_color $GREEN "✓ Environment $env validation passed"
    else
        print_color $RED "✗ Environment $env validation failed"
        print_color $YELLOW "Running helmfile template for detailed error:"
        helmfile --environment "$env" template --skip-deps
        exit 1
    fi
done

# Check if all required value template files exist
template_files=("nginx-values.yaml.gotmpl" "redis-values.yaml.gotmpl" "ingress-values.yaml.gotmpl")

for template in "${template_files[@]}"; do
    if [[ ! -f "values/${template}" ]]; then
        print_color $RED "Error: Template file values/${template} not found"
        exit 1
    else
        print_color $GREEN "✓ Template file values/${template} exists"
    fi
done

print_color $GREEN "All validations passed!"
print_color $BLUE "Helmfile configuration is ready for deployment."
