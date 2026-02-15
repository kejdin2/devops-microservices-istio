#!/usr/bin/env bash
set -euo pipefail

echo "[00] Namespace + Redis"

kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/redis.yaml

kubectl get ns devops --show-labels
kubectl get pods -n devops
