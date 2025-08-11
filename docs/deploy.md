# Deployment Guide

This document describes how to deploy the demo project to your Kubernetes cluster.

## 1. Ensure Prerequisites
- K3s or compatible Kubernetes cluster is running
- Helm and kubectl are installed

## 2. Deploy Database
```sh
cd postgresql
./deploy-postgresql-helm.sh
```

## 3. Deploy Application Services
```sh
cd deployment
kubectl apply -f app/
```

## 4. Deploy New Relic Monitoring
```sh
kubectl apply -f newrelic/
```

## 5. Verify Deployments
```sh
kubectl get pods -A
kubectl get svc -A
```

## 6. Access the Services
- Use `kubectl port-forward` or expose services as needed.
- Check logs with `kubectl logs` for troubleshooting.

---
For advanced deployment options, see the Kubernetes manifests in the `deployment/` folder.
