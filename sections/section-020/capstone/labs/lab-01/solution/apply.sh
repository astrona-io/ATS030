#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-030-capstone-020" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
solution_directory="$(cd "$(dirname "$0")" && pwd)"
kubectl apply -f "$solution_directory/service-probe.yaml"
kubectl apply -f "$solution_directory/service-probe-node.yaml"
kubectl apply -f "$solution_directory/service-probe-pods.yaml"
kubectl apply -f "$solution_directory/service-probe-external.yaml"
