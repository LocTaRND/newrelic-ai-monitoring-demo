#!/bin/bash

# Enhanced K3s Cluster Rename Script
# This script comprehensively renames k3s cluster, context, and user names in kubeconfig

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration
NEW_CLUSTER_NAME="${1:-k3s-cluster}"
KUBECONFIG_PATH="$HOME/.kube/config"
K3S_CONFIG_PATH="/etc/rancher/k3s/k3s.yaml"

# Function to wait for k3s lock release
wait_for_lock_release() {
    print_status "Checking for K3s config locks..."
    local timeout=30
    local count=0
    
    while [[ -f "${K3S_CONFIG_PATH}.lock" ]] && [[ $count -lt $timeout ]]; do
        print_status "Waiting for K3s to release config lock... ($count/$timeout)"
        sleep 1
        ((count++))
    done
    
    if [[ -f "${K3S_CONFIG_PATH}.lock" ]]; then
        print_warning "Lock file still exists after ${timeout}s, continuing anyway..."
    fi
}

# Function to backup existing kubeconfig
backup_kubeconfig() {
    if [[ -f "$KUBECONFIG_PATH" ]]; then
        local backup_path="${KUBECONFIG_PATH}.backup.$(date +%Y%m%d_%H%M%S)"
        print_status "Backing up existing kubeconfig to $backup_path"
        cp "$KUBECONFIG_PATH" "$backup_path"
        print_success "Backup created at $backup_path"
    fi
}

# Function to setup fresh kubeconfig from k3s
setup_kubeconfig() {
    print_status "Setting up kubeconfig from K3s..."
    
    # Create .kube directory if it doesn't exist
    mkdir -p "$HOME/.kube"
    
    # Check if k3s kubeconfig exists
    if [[ ! -f "$K3S_CONFIG_PATH" ]]; then
        print_error "K3s kubeconfig not found at $K3S_CONFIG_PATH"
        print_error "Make sure K3s is installed and running"
        exit 1
    fi
    
    # Wait for lock release and backup existing config
    wait_for_lock_release
    backup_kubeconfig
    
    # Copy fresh k3s config (using cat to avoid lock issues)
    print_status "Copying K3s configuration to $KUBECONFIG_PATH"
    sudo cat "$K3S_CONFIG_PATH" > "$KUBECONFIG_PATH"
    chown "$USER:$USER" "$KUBECONFIG_PATH"
    chmod 600 "$KUBECONFIG_PATH"
    
    print_success "Fresh kubeconfig copied from K3s"
}

# Function to extract credentials from original k3s config
extract_credentials() {
    print_status "Extracting credentials from K3s config..."
    
    # Extract credentials directly from k3s config file
    CLIENT_CERT_DATA=$(sudo grep "client-certificate-data:" "$K3S_CONFIG_PATH" | awk '{print $2}' | head -1)
    CLIENT_KEY_DATA=$(sudo grep "client-key-data:" "$K3S_CONFIG_PATH" | awk '{print $2}' | head -1)
    
    if [[ -z "$CLIENT_CERT_DATA" || -z "$CLIENT_KEY_DATA" ]]; then
        print_error "Failed to extract client credentials from K3s config"
        exit 1
    fi
    
    print_success "Credentials extracted successfully"
    echo "CLIENT_CERT_DATA=${CLIENT_CERT_DATA}"
    echo "CLIENT_KEY_DATA=${CLIENT_KEY_DATA}"
}

# Function to completely rebuild kubeconfig with new names
rebuild_kubeconfig() {
    print_status "Rebuilding kubeconfig with new names..."
    
    # Set KUBECONFIG environment variable
    export KUBECONFIG="$KUBECONFIG_PATH"
    
    # Extract current configuration
    SERVER_URL=$(kubectl config view --raw -o jsonpath='{.clusters[0].cluster.server}')
    CERT_AUTHORITY_DATA=$(kubectl config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')
    
    if [[ -z "$SERVER_URL" || -z "$CERT_AUTHORITY_DATA" ]]; then
        print_error "Failed to extract cluster configuration"
        exit 1
    fi
    
    print_status "Server URL: $SERVER_URL"
    print_status "Creating new cluster configuration..."
    
    # Remove all existing contexts, clusters, and users
    kubectl config delete-context default 2>/dev/null || true
    kubectl config delete-cluster default 2>/dev/null || true
    kubectl config delete-user default 2>/dev/null || true
    
    # Create new cluster
    kubectl config set-cluster "$NEW_CLUSTER_NAME" \
        --server="$SERVER_URL" \
        --certificate-authority-data="$CERT_AUTHORITY_DATA"
    
    # Extract and create new user credentials
    extract_credentials
    kubectl config set-credentials "$NEW_CLUSTER_NAME" \
        --client-certificate-data="$CLIENT_CERT_DATA" \
        --client-key-data="$CLIENT_KEY_DATA"
    
    # Create new context
    kubectl config set-context "$NEW_CLUSTER_NAME" \
        --cluster="$NEW_CLUSTER_NAME" \
        --user="$NEW_CLUSTER_NAME"
    
    # Set current context
    kubectl config use-context "$NEW_CLUSTER_NAME"
    
    print_success "Kubeconfig rebuilt with consistent naming!"
}

# Function to verify cluster connectivity
verify_cluster_connectivity() {
    print_status "Verifying cluster connectivity..."
    
    export KUBECONFIG="$KUBECONFIG_PATH"
    
    # Test basic connectivity
    if ! kubectl cluster-info &>/dev/null; then
        print_error "Failed to connect to cluster"
        print_status "Trying to diagnose the issue..."
        kubectl config view
        return 1
    fi
    
    # Test node access
    if ! kubectl get nodes &>/dev/null; then
        print_error "Failed to get cluster nodes"
        return 1
    fi
    
    print_success "Cluster connectivity verified!"
    return 0
}

# Function to display final configuration
show_final_config() {
    print_status "Final configuration summary:"
    
    export KUBECONFIG="$KUBECONFIG_PATH"
    
    echo
    echo "=== Contexts ==="
    kubectl config get-contexts
    
    echo
    echo "=== Clusters ==="
    kubectl config get-clusters
    
    echo
    echo "=== Users ==="
    kubectl config get-users
    
    echo
    echo "=== Cluster Info ==="
    kubectl cluster-info
    
    echo
    echo "=== Nodes ==="
    kubectl get nodes
}

# Function to set environment variables
setup_environment() {
    print_status "Setting up environment variables..."
    
    # Add KUBECONFIG to bashrc if not already present
    if ! grep -q "export KUBECONFIG=$KUBECONFIG_PATH" "$HOME/.bashrc" 2>/dev/null; then
        echo "export KUBECONFIG=$KUBECONFIG_PATH" >> "$HOME/.bashrc"
        print_success "Added KUBECONFIG to ~/.bashrc"
    else
        print_status "KUBECONFIG already in ~/.bashrc"
    fi
    
    # Export for current session
    export KUBECONFIG="$KUBECONFIG_PATH"
    print_status "KUBECONFIG set for current session"
}

# Function to validate prerequisites
validate_prerequisites() {
    print_status "Validating prerequisites..."
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root"
        print_error "Please run as a regular user with sudo privileges"
        exit 1
    fi
    
    # Check if kubectl is available
    if ! command -v kubectl &> /dev/null; then
        print_status "kubectl not found, installing..."
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        chmod +x kubectl
        sudo mv kubectl /usr/local/bin/
        print_success "kubectl installed"
    fi
    
    # Check if k3s is running
    if ! sudo systemctl is-active --quiet k3s; then
        print_error "K3s service is not running"
        print_status "Starting K3s service..."
        sudo systemctl start k3s
        sleep 10
        
        if ! sudo systemctl is-active --quiet k3s; then
            print_error "Failed to start K3s service"
            print_status "Please check K3s logs: sudo journalctl -u k3s -f"
            exit 1
        fi
        print_success "K3s service started"
    fi
    
    print_success "All prerequisites validated"
}

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS] [CLUSTER_NAME]

Enhanced K3s cluster rename script that renames cluster, context, and user consistently.

OPTIONS:
    -h, --help      Show this help message
    -f, --force     Force rebuild even if names already match
    -b, --backup    Create backup only, don't modify config

ARGUMENTS:
    CLUSTER_NAME    New name for cluster/context/user (default: k3s-cluster)

EXAMPLES:
    $0                          # Use default name 'k3s-cluster'
    $0 my-k3s-cluster          # Use custom name 'my-k3s-cluster'
    $0 --force production      # Force rebuild with name 'production'
    $0 --backup                # Create backup only

FEATURES:
    • Comprehensive renaming of cluster, context, and user
    • Automatic credential extraction and preservation
    • Backup creation with timestamps
    • Lock file handling for K3s compatibility
    • Environment variable setup
    • Connectivity verification

EOF
}

# Function to handle command line arguments
parse_arguments() {
    FORCE_REBUILD=false
    BACKUP_ONLY=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -f|--force)
                FORCE_REBUILD=true
                shift
                ;;
            -b|--backup)
                BACKUP_ONLY=true
                shift
                ;;
            -*)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
            *)
                NEW_CLUSTER_NAME="$1"
                shift
                ;;
        esac
    done
}

# Main execution function
main() {
    echo "=========================================="
    echo "   Enhanced K3s Cluster Rename Script    "
    echo "=========================================="
    echo
    
    parse_arguments "$@"
    
    print_status "Target cluster name: $NEW_CLUSTER_NAME"
    print_status "Force rebuild: $FORCE_REBUILD"
    print_status "Backup only: $BACKUP_ONLY"
    echo
    
    validate_prerequisites
    
    if [[ "$BACKUP_ONLY" == "true" ]]; then
        backup_kubeconfig
        print_success "Backup completed!"
        exit 0
    fi
    
    # Check if already properly configured
    if [[ -f "$KUBECONFIG_PATH" ]] && [[ "$FORCE_REBUILD" == "false" ]]; then
        export KUBECONFIG="$KUBECONFIG_PATH"
        current_context=$(kubectl config current-context 2>/dev/null || echo "")
        if [[ "$current_context" == "$NEW_CLUSTER_NAME" ]]; then
            print_status "Cluster already named '$NEW_CLUSTER_NAME'"
            if verify_cluster_connectivity; then
                print_success "Configuration is already correct and working!"
                show_final_config
                exit 0
            fi
        fi
    fi
    
    setup_kubeconfig
    rebuild_kubeconfig
    
    if verify_cluster_connectivity; then
        setup_environment
        show_final_config
        
        echo
        print_success "K3s cluster rename completed successfully!"
        print_status "Cluster name: $NEW_CLUSTER_NAME"
        print_status "Config location: $KUBECONFIG_PATH"
        print_status "To apply environment changes, run: source ~/.bashrc"
        echo
    else
        print_error "Configuration completed but connectivity test failed"
        print_status "Please check the cluster status and try again"
        exit 1
    fi
}

# Execute main function with all arguments
main "$@"