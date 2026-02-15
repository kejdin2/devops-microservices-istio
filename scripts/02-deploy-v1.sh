#!/usr/bin/env bash
set -euo pipefail

echo "[02] Deploy v1 (A, B, C, Gateway) with replicas=3"

kubectl apply -f k8s/apps/service-a/v1.yaml
kubectl apply -f k8s/apps/service-b/v1.yaml
kubectl apply -f k8s/apps/service-c/v1.yaml
kubectl apply -f k8s/apps/frontend-gateway/v1.yaml


kubectl get pods -n devops
kubectl get svc -n devops
