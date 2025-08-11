# Setup Guide

This guide will walk you through setting up the demo project from scratch.

## Prerequisites
- Docker & Docker Compose
- Kubernetes (K3s recommended)
- Helm 3.x
- .NET 8 SDK
- Node.js 16+
- Python 3.9+

## 1. Clone the Repository
```sh
git clone <your-repo-url>
cd demo
```

## 2. Set Up K3s Cluster
```sh
cd k3s-setup
chmod +x setup-k3s.sh
./setup-k3s.sh
```

## 3. Deploy PostgreSQL
```sh
cd postgresql
chmod +x deploy-postgresql-helm.sh
./deploy-postgresql-helm.sh
```

## 4. Configure Secrets
Copy the template and edit with your values:
```sh
cp deployment/secrets/secrets.yaml.template deployment/secrets/secrets.yaml
```

## 5. Deploy Applications
```sh
cd deployment
kubectl apply -f app/
kubectl apply -f newrelic/
```

---
For more details, see the individual service READMEs or Dockerfiles.
