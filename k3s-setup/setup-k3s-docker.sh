#!/bin/bash

# K3s + Docker + Helm Setup Script for Ubuntu
# This script installs and configures Docker, K3s and Helm on Ubuntu

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root. Please run as a regular user with sudo privileges."
        exit 1
    fi
}

# Check Ubuntu version
check_ubuntu() {
    if ! command -v lsb_release &> /dev/null; then
        print_error "lsb_release not found. Are you running Ubuntu?"
        exit 1
    fi
    
    OS=$(lsb_release -si)
    VERSION=$(lsb_release -sr)
    
    if [[ "$OS" != "Ubuntu" ]]; then
        print_error "This script is designed for Ubuntu. Detected: $OS"
        exit 1
    fi
    
    print_status "Detected Ubuntu $VERSION"
}

# Update system packages
update_system() {
    print_status "Updating system packages..."
    sudo apt update
    sudo apt upgrade -y
    print_success "System packages updated"
}

# Install required dependencies
install_dependencies() {
    print_status "Installing required dependencies..."
    sudo apt install -y \
        curl \
        wget \
        apt-transport-https \
        ca-certificates \
        gnupg \
        lsb-release \
        iptables \
        software-properties-common
    print_success "Dependencies installed"
}

# Install Docker (full installation)
install_docker() {
    if ! command -v docker &> /dev/null; then
        print_status "Installing Docker..."
        
        # Remove any old Docker installations
        sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
        
        # Add Docker's official GPG key
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        
        # Add Docker repository
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
          $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        # Update package index
        sudo apt update
        
        # Install Docker Engine, containerd, and Docker Compose
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        
        # Add current user to docker group
        sudo usermod -aG docker $USER
        
        # Start and enable Docker service
        sudo systemctl start docker
        sudo systemctl enable docker
        
        print_success "Docker installed successfully"
        
        # Verify Docker installation
        if sudo docker --version &> /dev/null; then
            print_status "Docker version: $(sudo docker --version)"
            print_status "Docker Compose version: $(sudo docker compose version)"
        else
            print_error "Docker installation verification failed"
            return 1
        fi
        
        print_warning "You'll need to log out and back in (or restart) for Docker group membership to take effect"
        print_status "Or run 'newgrp docker' to refresh group membership in current session"
        
    else
        print_status "Docker already installed"
        print_status "Docker version: $(docker --version)"
    fi
}

# Configure Docker daemon for K3s compatibility
configure_docker() {
    print_status "Configuring Docker for K3s compatibility..."
    
    # Create Docker daemon configuration
    sudo mkdir -p /etc/docker
    
    # Configure Docker daemon with systemd cgroup driver
    cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
    
    # Restart Docker to apply configuration
    sudo systemctl restart docker
    
    print_success "Docker configured for K3s compatibility"
}

# Configure system for K3s
configure_system() {
    print_status "Configuring system for K3s..."
    
    # Enable IP forwarding
    echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
    echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
    
    # Configure iptables to use legacy mode (if needed)
    sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
    sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
    
    print_success "System configured for K3s"
}

# Install K3s with Docker runtime
install_k3s() {    
    print_status "Installing K3s with Docker runtime..."
    
    # Download and install K3s with Docker as container runtime
    curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="v1.30.8+k3s1" INSTALL_K3S_EXEC="--docker" sh -
    
    # Wait for K3s to start
    print_status "Waiting for K3s to start..."
    sleep 30
    
    # Check if K3s is running
    if sudo systemctl is-active --quiet k3s; then
        print_success "K3s installed and running with Docker runtime"
        
        # Display cluster info
        print_status "Cluster information:"
        sudo k3s kubectl get nodes
        sudo k3s kubectl cluster-info
    else
        print_error "K3s installation failed or service is not running"
        print_status "Checking service status:"
        sudo systemctl status k3s --no-pager
        exit 1
    fi
}

# Configure kubectl access for current user
configure_kubectl() {
    print_status "Configuring kubectl access..."
    
    # Create .kube directory
    mkdir -p $HOME/.kube
    
    # Copy K3s config
    sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    chmod 600 $HOME/.kube/config
    
    # Set KUBECONFIG environment variable
    echo 'export KUBECONFIG=$HOME/.kube/config' >> $HOME/.bashrc
    export KUBECONFIG=$HOME/.kube/config
    
    print_success "kubectl configured for current user"
}

# Install kubectl (if not already available)
install_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        print_status "Installing kubectl..."
        
        # Download kubectl
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        
        # Install kubectl
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        rm kubectl
        
        print_success "kubectl installed"
    else
        print_status "kubectl already installed"
    fi
}

# Install Helm
install_helm() {
    if ! command -v helm &> /dev/null; then
        print_status "Installing Helm..."
        
        # Download and install Helm using the official script
        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
        
        # Verify Helm installation
        if command -v helm &> /dev/null; then
            print_success "Helm installed successfully"
            print_status "Helm version: $(helm version --short)"
        else
            print_error "Helm installation failed"
            return 1
        fi
    else
        print_status "Helm already installed"
        print_status "Helm version: $(helm version --short)"
    fi
}

# Configure Helm repositories
configure_helm() {
    print_status "Configuring Helm repositories..."
    
    # Add popular Helm repositories
    helm repo add stable https://charts.helm.sh/stable 2>/dev/null || true
    helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null || true
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx 2>/dev/null || true
    helm repo add jetstack https://charts.jetstack.io 2>/dev/null || true
    helm repo add newrelic https://helm-charts.newrelic.com 2>/dev/null || true
    
    # Update repositories
    helm repo update
    
    print_success "Helm repositories configured and updated"
    
    # List available repositories
    print_status "Available Helm repositories:"
    helm repo list
}

# Verify installation
verify_installation() {
    print_status "Verifying installations..."
    
    # Check Docker
    if sudo docker run hello-world &> /dev/null; then
        print_success "Docker is working correctly"
    else
        print_error "Docker test failed"
        return 1
    fi
    
    # Check K3s service status
    if sudo systemctl is-active --quiet k3s; then
        print_success "K3s service is active"
    else
        print_error "K3s service is not active"
        return 1
    fi
    
    # Wait a bit more for nodes to be ready
    sleep 10
    
    # Check cluster status
    if kubectl get nodes &> /dev/null; then
        print_success "Cluster is accessible via kubectl"
        echo
        print_status "Cluster information:"
        kubectl get nodes -o wide
        echo
        kubectl cluster-info
    else
        print_error "Unable to access cluster via kubectl"
        return 1
    fi
    
    # Verify Helm can connect to cluster
    print_status "Verifying Helm installation..."
    if helm list &> /dev/null; then
        print_success "Helm can access the cluster"
    else
        print_error "Helm cannot access the cluster"
        return 1
    fi
    
    # Check Docker runtime in K3s
    print_status "Verifying K3s is using Docker runtime..."
    if kubectl get nodes -o wide | grep -q "docker://"; then
        print_success "K3s is using Docker as container runtime"
    else
        print_warning "K3s may not be using Docker runtime (this might be normal)"
    fi
}

# Display post-installation information
post_install_info() {
    echo
    print_success "Docker, K3s and Helm installation completed successfully!"
    echo
    print_status "Important information:"
    echo "  • Docker config: /etc/docker/daemon.json"
    echo "  • Docker service: sudo systemctl {start|stop|restart|status} docker"
    echo "  • K3s config file: /etc/rancher/k3s/k3s.yaml"
    echo "  • K3s data directory: /var/lib/rancher/k3s/"
    echo "  • K3s service: sudo systemctl {start|stop|restart|status} k3s"
    echo "  • Uninstall K3s: /usr/local/bin/k3s-uninstall.sh"
    echo "  • Helm config directory: ~/.config/helm/"
    echo "  • Helm cache directory: ~/.cache/helm/"
    echo
    print_status "To use kubectl and helm, run: source ~/.bashrc"
    print_warning "To use Docker without sudo, log out and back in, or run: newgrp docker"
    echo
    print_status "Useful Docker commands:"
    echo "  • Check status: docker info"
    echo "  • List containers: docker ps"
    echo "  • List images: docker images"
    echo "  • Run container: docker run <image>"
    echo "  • Build image: docker build -t <name> ."
    echo
    print_status "Useful Helm commands:"
    echo "  • List repositories: helm repo list"
    echo "  • Search charts: helm search repo <keyword>"
    echo "  • Install chart: helm install <release-name> <chart>"
    echo "  • List releases: helm list"
    echo "  • Uninstall release: helm uninstall <release-name>"
    echo
    print_status "Example Helm installations:"
    echo "  • Nginx Ingress: helm install nginx-ingress ingress-nginx/ingress-nginx"
    echo "  • Cert-Manager: helm install cert-manager jetstack/cert-manager --set installCRDs=true"
    echo "  • Prometheus: helm install prometheus bitnami/kube-prometheus"
    echo
    print_status "To add worker nodes, run this on other machines:"
    echo "  curl -sfL https://get.k3s.io | K3S_URL=https://$(hostname -I | awk '{print $1}'):6443 K3S_TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token) INSTALL_K3S_EXEC='--docker' sh -"
    echo
}

# Main installation function
main() {
    echo "==============================================="
    echo "     Docker + K3s + Helm Ubuntu Setup Script "
    echo "==============================================="
    echo
    
    check_root
    check_ubuntu
    
    print_status "Starting Docker, K3s and Helm installation process..."
    echo
    
    update_system
    install_dependencies
    install_docker
    configure_docker
    configure_system
    install_k3s
    configure_kubectl
    install_kubectl
    install_helm
    configure_helm
    
    if verify_installation; then
        post_install_info
    else
        print_error "Installation verification failed. Please check the logs above."
        exit 1
    fi
}

# Run main function
main "$@"