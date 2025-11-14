#!/bin/bash

echo "=== PostgreSQL Deployment with Bitnami Helm Chart ==="

# Create namespace
kubectl create namespace database --dry-run=client -o yaml | kubectl apply -f -

# Add Bitnami repository
echo "Adding Bitnami Helm repository..."
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Create ConfigMap from external init-db.sql file
echo "Creating ConfigMap for database initialization..."
kubectl create configmap postgresql-initdb \
  --from-file=init-db.sql \
  --namespace database \
  --dry-run=client -o yaml | kubectl apply -f -

# Create values file
cat <<EOF > postgresql-values.yaml
auth:
  postgresPassword: "supersecret"
  username: "appuser"
  password: "apppassword"
  database: "testdb"

primary:
  persistence:
    enabled: true
    size: 10Gi
  
  initdb:
    scriptsConfigMap: postgresql-initdb

  resources:
    requests:
      memory: "256Mi"
      cpu: "250m"
    limits:
      memory: "512Mi"
      cpu: "500m"

# Optional: Enable read replicas for HA
readReplicas:
  replicaCount: 0

# Optional: Enable metrics
metrics:
  enabled: true
  serviceMonitor:
    enabled: false
EOF

# Deploy PostgreSQL
echo "Deploying PostgreSQL with Bitnami chart..."
helm upgrade --install postgresql bitnami/postgresql \
  --namespace database \
  --values postgresql-values.yaml \
  --wait \
  --timeout 10m

# Get password
export POSTGRES_PASSWORD=$(kubectl get secret --namespace database postgresql -o jsonpath="{.data.postgres-password}" | base64 --decode)

echo ""
echo "=== Testing Database Connection ==="
kubectl exec -n database postgresql-0 -- env PGPASSWORD="$POSTGRES_PASSWORD" psql -U postgres -d testdb -c "SELECT version();"

echo ""
echo "=== Checking Tables ==="
kubectl exec -n database postgresql-0 -- env PGPASSWORD="$POSTGRES_PASSWORD" psql -U postgres -d testdb -c "\dt"

echo ""
echo "=== Checking Users ==="
kubectl exec -n database postgresql-0 -- env PGPASSWORD="$POSTGRES_PASSWORD" psql -U postgres -d testdb -c "SELECT * FROM users;"

echo ""
echo "=== Connection Information ==="
echo "Host: postgresql.database.svc.cluster.local"
echo "Port: 5432"
echo "Database: testdb"
echo "Username: appuser / postgres"
echo "Password: [stored in secret 'postgresql']"

echo ""
echo "=== Deployment Status ==="
kubectl get all -n database

echo ""
echo "✅ PostgreSQL deployment completed!"
echo ""
echo "⚠️  NOTE: Consider migrating to CloudNativePG for production use"
echo "   Bitnami is moving to a paid model after September 2025"