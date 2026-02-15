#!/usr/bin/env bash
set -euo pipefail

echo "[06] Deploy v2 for ALL + route ALL traffic to v2 (clean, deterministic)"

kubectl delete virtualservice -n devops vs-service-a-ab vs-service-c-ab --ignore-not-found
kubectl delete virtualservice -n devops vs-service-a-all-v1 vs-service-b-all-v1 vs-service-c-all-v1 --ignore-not-found

kubectl apply -f k8s/apps/service-a/v2.yaml
kubectl apply -f k8s/apps/service-b/v2.yaml
kubectl apply -f k8s/apps/service-c/v2.yaml
kubectl apply -f k8s/apps/frontend-gateway/v2.yaml

kubectl apply -f k8s/istio/destination-rules.yaml

kubectl apply -f k8s/istio/virtual-services/all-v2.yaml

cat <<'YAML' | kubectl apply -f -
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: frontend-gateway-vs
  namespace: devops
spec:
  hosts:
    - "*"
  gateways:
    - devops/devops-gateway
  http:
    - match:
        - uri:
            prefix: /api/
      route:
        - destination:
            host: frontend-gateway
            subset: v2
            port:
              number: 80
YAML

echo "Waiting for v2 deployments to be ready..."
kubectl -n devops rollout status deployment/service-a-v2 --timeout=180s
kubectl -n devops rollout status deployment/service-b-v2 --timeout=180s
kubectl -n devops rollout status deployment/service-c-v2 --timeout=180s
kubectl -n devops rollout status deployment/frontend-gateway-v2 --timeout=180s
echo "All v2 deployments are READY."

echo "Waiting for service-b endpoints to be ready..."
for i in 1 2 3 4 5 6 7 8 9 10; do
  READY="$(kubectl get endpoints -n devops service-b -o jsonpath='{.subsets[0].addresses[0].ip}' 2>/dev/null || true)"
  if [ -n "$READY" ]; then
    echo "service-b endpoints look ready."
    break
  fi
  echo "  endpoints not ready yet ($i/10), waiting 2s..."
  sleep 2
done

echo ""
echo "Active VirtualServices:"
kubectl get virtualservice -n devops
echo ""
echo "Done."

