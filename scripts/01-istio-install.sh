#!/usr/bin/env bash
set -euo pipefail

echo "[01] Istio check + apply gateway + ingress VS"

kubectl apply -f k8s/istio/gateway.yaml
kubectl apply -f k8s/istio/ingress-gateway.yaml

kubectl get gateway -n devops
kubectl get virtualservice -n devops | grep -E "frontend-gateway-vs" || true
