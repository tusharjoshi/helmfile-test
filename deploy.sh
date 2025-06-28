#!/bin/bash

# Helmfile Deployment Scripts
# This script provides easy commands to deploy the helmfile to different environments

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to check if helmfile is installed
check_helmfile() {
    if ! command -v helmfile &> /dev/null; then
        print_color $RED "Error: helmfile is not installed"
        print_color $YELLOW "Please install helmfile: https://github.com/helmfile/helmfile"
        exit 1
    fi
}

# Function to check if helm is installed
check_helm() {
    if ! command -v helm &> /dev/null; then
        print_color $RED "Error: helm is not installed"
        print_color $YELLOW "Please install helm: https://helm.sh/docs/intro/install/"
        exit 1
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [COMMAND] [ENVIRONMENT] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  deploy      Deploy the helmfile"
    echo "  diff        Show diff of changes"
    echo "  destroy     Destroy all releases"
    echo "  status      Show status of releases"
    echo "  template    Generate templates without deploying"
    echo "  sync        Sync releases (deploy + cleanup)"
    echo ""
    echo "Environments:"
    echo "  default     Default environment"
    echo "  development Development environment"
    echo "  staging     Staging environment"
    echo "  production  Production environment"
    echo ""
    echo "Options:"
    echo "  --dry-run   Show what would be deployed without actually deploying"
    echo "  --debug     Enable debug output"
    echo ""
    echo "Examples:"
    echo "  $0 deploy development"
    echo "  $0 diff production"
    echo "  $0 sync staging --dry-run"
    echo "  $0 status"
}

# Function to deploy helmfile
deploy_helmfile() {
    local env=${1:-default}
    local dry_run=${2:-false}
    
    print_color $BLUE "Deploying helmfile to environment: $env"
    
    if [ "$dry_run" = "true" ]; then
        print_color $YELLOW "Running in dry-run mode..."
        helmfile --environment "$env" --debug apply --dry-run
    else
        helmfile --environment "$env" apply
    fi
}

# Function to show diff
show_diff() {
    local env=${1:-default}
    
    print_color $BLUE "Showing diff for environment: $env"
    helmfile --environment "$env" diff
}

# Function to destroy releases
destroy_releases() {
    local env=${1:-default}
    
    print_color $RED "Destroying releases in environment: $env"
    read -p "Are you sure? This will delete all resources. (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        helmfile --environment "$env" destroy
        print_color $GREEN "Destruction complete"
    else
        print_color $YELLOW "Destruction cancelled"
    fi
}

# Function to show status
show_status() {
    local env=${1:-default}
    
    print_color $BLUE "Showing status for environment: $env"
    helmfile --environment "$env" status
}

# Function to generate templates
generate_templates() {
    local env=${1:-default}
    
    print_color $BLUE "Generating templates for environment: $env"
    helmfile --environment "$env" template
}

# Function to sync releases
sync_releases() {
    local env=${1:-default}
    local dry_run=${2:-false}
    
    print_color $BLUE "Syncing releases in environment: $env"
    
    if [ "$dry_run" = "true" ]; then
        print_color $YELLOW "Running in dry-run mode..."
        helmfile --environment "$env" --debug sync --dry-run
    else
        helmfile --environment "$env" sync
    fi
}

# Main script logic
main() {
    check_helmfile
    check_helm
    
    local command=$1
    local environment=$2
    local dry_run=false
    local debug=false
    
    # Parse additional arguments
    shift 2 2>/dev/null || true
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                dry_run=true
                shift
                ;;
            --debug)
                debug=true
                shift
                ;;
            *)
                print_color $RED "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    case $command in
        deploy)
            deploy_helmfile "$environment" "$dry_run"
            ;;
        diff)
            show_diff "$environment"
            ;;
        destroy)
            destroy_releases "$environment"
            ;;
        status)
            show_status "$environment"
            ;;
        template)
            generate_templates "$environment"
            ;;
        sync)
            sync_releases "$environment" "$dry_run"
            ;;
        *)
            print_color $RED "Unknown command: $command"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [ $# -eq 0 ]; then
        show_usage
        exit 1
    fi
    main "$@"
fi
