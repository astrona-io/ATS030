#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-030-lab-010-03-01" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
solution_directory="$(cd "$(dirname "$0")" && pwd)"
kubectl apply -f "$solution_directory/networkpolicy-default-deny-ingress.yaml"
kubectl apply -f "$solution_directory/networkpolicy-probe-from-drifter.yaml"
