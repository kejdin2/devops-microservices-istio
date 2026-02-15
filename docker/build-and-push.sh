#!/usr/bin/env bash
set -euo pipefail

REGISTRY_PREFIX="docker.io/YOUR_DOCKERHUB_USER"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

build_one () {
  local app="$1"  
  local ver="$2"   
  local img="${REGISTRY_PREFIX}/${app}:${ver}"

  echo "=================================================="
  echo "Building: ${img}"
  echo "Context:  ${ROOT_DIR}/apps/${app}/${ver}"
  echo "=================================================="

  docker build -t "${img}" "${ROOT_DIR}/apps/${app}/${ver}"
  docker push "${img}"
}

build_one "frontend-gateway" "v1"
build_one "frontend-gateway" "v2"

build_one "service-a" "v1"
build_one "service-a" "v2"

build_one "service-b" "v1"
build_one "service-b" "v2"

build_one "service-c" "v1"
build_one "service-c" "v2"

echo "✅ Done. Images pushed under: ${REGISTRY_PREFIX}"
