#!/usr/bin/env bash
set -euo pipefail

echo "[05-demo] Prepare deterministic A/B test state (A,C v2 + header routing)"

# Reset routing to baseline v1
bash scripts/99-reset-routing.sh

bash scripts/03-deploy-v2-two.sh

echo ""
echo "v2 deployments present:"
kubectl get deploy -n devops | grep v2 || true
echo ""


kubectl delete virtualservice -n devops vs-service-a-all-v1 vs-service-c-all-v1 --ignore-not-found

bash scripts/05-ab-test.sh

kubectl apply -f k8s/istio/virtual-services/routing-header.yaml

echo ""
echo "VirtualServices for A/C now:"
kubectl get virtualservice -n devops | grep -E "service-a|service-c" || true

echo ""
echo "Done. Now run PowerShell demo vs canary tests via http://localhost:8088"
