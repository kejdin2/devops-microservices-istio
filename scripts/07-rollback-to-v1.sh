#!/usr/bin/env bash
set -euo pipefail

echo "[07] Rollback routing to v1 (clean, deterministic)"

kubectl delete virtualservice -n devops vs-service-a-ab vs-service-c-ab --ignore-not-found
kubectl delete virtualservice -n devops vs-service-a-all-v2 vs-service-b-all-v2 vs-service-c-all-v2 --ignore-not-found
kubectl delete virtualservice -n devops vs-frontend-gateway-all-v2 --ignore-not-found

kubectl apply -f k8s/istio/virtual-services/all-v1.yaml

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
            subset: v1
            port:
              number: 80
YAML

kubectl get virtualservice -n devops
echo "Done."
