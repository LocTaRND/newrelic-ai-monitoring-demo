#!/bin/bash

# PostgreSQL Deployment Script using Helm

echo "=== PostgreSQL Deployment on Kubernetes ==="

# Create namespace for database
echo "Creating database namespace..."
kubectl create namespace database --dry-run=client -o yaml | kubectl apply -f -

# Create ConfigMap for database initialization
echo "Creating database initialization scripts..."
kubectl create configmap postgresql-initdb \
  --from-file=init-db.sql \
  --namespace database \
  --dry-run=client -o yaml | kubectl apply -f -

# Add Bitnami Helm repository
echo "Adding Bitnami Helm repository..."
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Deploy PostgreSQL using Helm
echo "Deploying PostgreSQL..."
helm upgrade --install postgresql bitnami/postgresql \
  --namespace database \
  --values postgresql-helm-values.yaml \
  --version 16.7.4

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=postgresql -n database --timeout=300s

# Get PostgreSQL password
echo "Retrieving PostgreSQL password..."
export POSTGRES_PASSWORD=$(kubectl get secret --namespace database postgresql -o jsonpath="{.data.postgres-password}" | base64 --decode)

# Wait a bit more for the database to be fully ready
echo "Waiting for database to be fully initialized..."
sleep 30

# Test database connection and show tables
echo "Testing database connection..."
kubectl exec -n database postgresql-0 -- env PGPASSWORD="$POSTGRES_PASSWORD" psql -U postgres -d postgres -c "SELECT version();"

# Connect to testdb and show tables
echo "Checking testdb database..."
kubectl exec -n database postgresql-0 -- env PGPASSWORD="$POSTGRES_PASSWORD" psql -U postgres -d testdb -c "\dt"

# Show users table if it exists
echo "Checking users table..."
kubectl exec -n database postgresql-0 -- env PGPASSWORD="$POSTGRES_PASSWORD" psql -U postgres -d testdb -c "SELECT COUNT(*) as user_count FROM users;" 2>/dev/null || echo "Users table not found (will be created by init script)"

# Execute database initialization
echo "Initializing database schema..."
kubectl exec -n database postgresql-0 -- env PGPASSWORD="$POSTGRES_PASSWORD" psql -U postgres -d testdb -c "\dt"

# Manual initialization if configmap didn't work
echo "Running manual database initialization..."
kubectl cp init-db.sql database/postgresql-0:/tmp/init-db.sql
kubectl exec -n database postgresql-0 -- env PGPASSWORD="$POSTGRES_PASSWORD" psql -U postgres -d testdb -f /tmp/init-db.sql

# Verify tables were created
echo "Verifying database initialization..."
kubectl exec -n database postgresql-0 -- env PGPASSWORD="$POSTGRES_PASSWORD" psql -U postgres -d testdb -c "SELECT tablename FROM pg_tables WHERE schemaname = 'public';"

# Get PostgreSQL connection information
echo "=== PostgreSQL Connection Information ==="
echo "Host: postgresql.database.svc.cluster.local"
echo "Port: 5432"
echo "Database: testdb"
echo "Username: appuser"
echo "Postgres Username: postgres"

# Get the password (for testing purposes)
echo "Postgres password: $POSTGRES_PASSWORD"
echo "App user password: apppassword (from helm values)"

# Show status
echo "=== Deployment Status ==="
kubectl get pods -n database
kubectl get svc -n database

# Show logs for troubleshooting
echo "=== PostgreSQL Logs (last 10 lines) ==="
kubectl logs -n database postgresql-0 --tail=10

echo "PostgreSQL deployment completed!"

