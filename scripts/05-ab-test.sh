#!/usr/bin/env bash
set -euo pipefail

echo "[05] A/B routing by header (X-type: canary -> v2, else v1) for A and C"

kubectl apply -f k8s/istio/destination-rules.yaml
kubectl apply -f k8s/istio/virtual-services/routing-header.yaml

kubectl get destinationrule -n devops
kubectl get virtualservice -n devops | grep -E "vs-service-a-ab|vs-service-c-ab" || true
