#!/bin/bash


# Usage: ./script.sh [apply|delete] [force]
ACTION=${1:-apply}
FORCE=${2:-}

VALUES_FILE="newrelic/values.yaml"
CHECKSUM_FILE=".values_checksum"

if [[ "$ACTION" == "apply" ]]; then
    # Setup NewRelic
    echo "Setting up NewRelic..."
    NEW_CHECKSUM=$(sha256sum "$VALUES_FILE" | awk '{print $1}')
    if [[ ! -f "$CHECKSUM_FILE" ]]; then
        echo ".values_checksum not found — this looks like a first-time New Relic setup. Deploying newrelic-bundle..."
        OLD_CHECKSUM=""
    else
        OLD_CHECKSUM=$(cat "$CHECKSUM_FILE")
    fi
    echo "NEW_CHECKSUM: $NEW_CHECKSUM and OLD_CHECKSUM: $OLD_CHECKSUM"

    if [[ "$FORCE" == "force" ]]; then
        echo "Force flag detected — deploying newrelic-bundle regardless of checksum."
        helm repo update
        helm upgrade --install newrelic-bundle newrelic/nri-bundle \
            -n newrelic --values "$VALUES_FILE" --create-namespace
        echo "$NEW_CHECKSUM" > "$CHECKSUM_FILE"
        sleep 60  # Wait for the newrelic-bundle to be ready
    elif [[ "$NEW_CHECKSUM" != "$OLD_CHECKSUM" ]]; then
        echo "values.yaml changed or first-time setup — deploying newrelic-bundle..."
        helm repo update
        helm upgrade --install newrelic-bundle newrelic/nri-bundle \
            -n newrelic --values "$VALUES_FILE" --create-namespace
        echo "$NEW_CHECKSUM" > "$CHECKSUM_FILE"
        sleep 60  # Wait for the newrelic-bundle to be ready
    else
        echo "values.yaml unchanged — skipping newrelic-bundle deployment."
    fi

    # Deploy newrelic config + instrumentation
    kubectl apply -f newrelic/instrumentation.yaml 
    kubectl apply -f newrelic/newrelic-config.yaml

    # Generate and apply secrets
    jq '.' appsettings.test.json > appsettings.json
    export appSettingsBase64=$(cat "appsettings.json" | base64 -w 0)
    envsubst < secret.yaml > app/secret-backend.yaml

    kubectl apply -f secrets/ -n default

    # Deploy application resources
    kubectl apply -f app/ -n default

    # Clean up
    rm appsettings.json
    rm app/secret-backend.yaml

    # Check if the secret was created successfully
    if kubectl get secret appsettings-backend -n default &> /dev/null; then
        echo "Secret created successfully."
    else
        echo "Failed to create secret."
        exit 1
    fi

    # Wait for backend-api pod to be running
    echo "Waiting for backend-api pod to be running..."
    kubectl wait --for=condition=Ready pod -l app=backend-api -n default --timeout=120s

    if [ $? -eq 0 ]; then
        echo "backend-api pod is running."
    else
        echo "backend-api pod failed to reach running state."
        kubectl get pods -n default
        exit 1
    fi

    # Wait for frontend (node) pod to be running
    echo "Waiting for frontend pod to be running..."
    kubectl wait --for=condition=Ready pod -l app=frontend -n default --timeout=120s

    if [ $? -eq 0 ]; then
        echo "frontend pod is running."
    else
        echo "frontend pod failed to reach running state."
        kubectl get pods -n default
        exit 1
    fi

    # Wait for ai-chatbot (node) pod to be running
    echo "Waiting for ai-chatbot pod to be running..."
    kubectl wait --for=condition=Ready pod -l app=ai-chatbot -n default --timeout=120s

    if [ $? -eq 0 ]; then
        echo "ai-chatbot pod is running."
    else
        echo "ai-chatbot pod failed to reach running state."
        kubectl get pods -n default
        exit 1
    fi    
elif [[ "$ACTION" == "delete" ]]; then
    echo "Deleting resources..."
    kubectl delete -f app/ -n default
    kubectl delete -f secrets/ -n default
else
    echo "Usage: $0 [apply|delete]"
    exit 1
fi