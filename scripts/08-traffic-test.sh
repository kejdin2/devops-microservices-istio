#!/usr/bin/env bash
set -euo pipefail

echo "[08] Traffic tests (in-cluster)"

kubectl run tmp-curl -n devops \
  --image=curlimages/curl \
  --restart=Never \
  -- sleep 3600 >/dev/null 2>&1 || true

echo "Waiting for curl pod..."
kubectl wait --for=condition=Ready pod/tmp-curl -n devops --timeout=60s

echo "== service-a /info =="
kubectl exec -n devops tmp-curl -- curl -s http://service-a/api/info
echo

echo "== service-b /handle =="
OUT=""
sleep 3
for i in 1 2 3 4 5 6 7 8 9 10; do
  OUT="$(kubectl exec -n devops tmp-curl -- curl -sS -X POST http://service-b/api/handle \
    -H "Content-Type: application/json" \
    -H "X-type: demo" \
    -H "X-Session: abc123" \
    -d '{"action":"createOrder","orderId":"B-777"}' 2>&1)" && break || true
  echo "  retry $i/10 failed, waiting..."
  sleep 2
done
echo "$OUT"
echo

echo "== service-c /handle =="
kubectl exec -n devops tmp-curl -- curl -s http://service-c/api/handle \
  -H "Content-Type: application/json" \
  -H "X-type: demo" \
  -H "X-Session: abc123" \
  -d '{"action":"getProfile","userId":"C-42"}'
echo

kubectl delete pod tmp-curl -n devops --ignore-not-found >/dev/null 2>&1

echo "== done =="
