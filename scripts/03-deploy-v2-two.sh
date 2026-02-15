#!/usr/bin/env bash
set -euo pipefail

echo "[03] Deploy v2 for TWO services only (A and C). Remove other v2 first."

kubectl delete deployment -n devops service-b-v2 frontend-gateway-v2 --ignore-not-found >/dev/null 2>&1 || true
kubectl delete virtualservice -n devops vs-service-b-all-v2 vs-frontend-gateway-all-v2 --ignore-not-found >/dev/null 2>&1 || true

kubectl apply -f k8s/apps/service-a/v2.yaml
kubectl apply -f k8s/apps/service-c/v2.yaml

echo "v2 deployments currently present:"
kubectl get deploy -n devops | grep v2 || true
