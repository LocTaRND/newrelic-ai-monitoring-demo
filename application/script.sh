#!/bin/bash
set -euo pipefail

# Docker Hub username (change if needed)
DOCKER_USER="taloc"

# List of services: directory | image-name
services=(
  "dotnet|dotnet-demo"
  "react-crud-app|nodejs-demo"
  "python|newrelic-ai"
)

for service in "${services[@]}"; do
  dir="${service%%|*}"
  image="${service##*|}"

  echo "=== Building $image from $dir ==="
  docker build -t "$DOCKER_USER/$image:latest" -f "$dir/Dockerfile" "$dir"

  echo "=== Pushing $image ==="
  docker push "$DOCKER_USER/$image:latest"
done

echo "✅ All images built and pushed successfully!"

