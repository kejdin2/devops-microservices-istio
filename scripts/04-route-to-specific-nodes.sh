#!/usr/bin/env bash
set -euo pipefail

echo "[04] Node routing demo (single-node safe): nodegroup=devops"

kubectl label node docker-desktop nodegroup=devops --overwrite

cat > /tmp/patch-node-devops.json <<'JSON'
{
  "spec": {
    "template": {
      "spec": {
        "nodeSelector": {
          "nodegroup": "devops"
        }
      }
    }
  }
}
JSON

kubectl -n devops patch deployment service-a-v1 --type merge --patch-file /tmp/patch-node-devops.json || true
kubectl -n devops patch deployment service-a-v2 --type merge --patch-file /tmp/patch-node-devops.json || true
kubectl -n devops patch deployment service-b-v1 --type merge --patch-file /tmp/patch-node-devops.json || true
kubectl -n devops patch deployment service-c-v1 --type merge --patch-file /tmp/patch-node-devops.json || true
kubectl -n devops patch deployment service-c-v2 --type merge --patch-file /tmp/patch-node-devops.json || true
kubectl -n devops patch deployment frontend-gateway-v1 --type merge --patch-file /tmp/patch-node-devops.json || true
kubectl -n devops patch deployment frontend-gateway-v2 --type merge --patch-file /tmp/patch-node-devops.json || true

echo "Pods and nodes:"
kubectl get pods -n devops -o wide
