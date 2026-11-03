#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-030-capstone-010" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
solution_directory="$(cd "$(dirname "$0")" && pwd)"
kubectl -n starfleet delete networkpolicy allow-everything --ignore-not-found
kubectl apply -f "$solution_directory/networkpolicy-default-deny-all.yaml"
kubectl apply -f "$solution_directory/networkpolicy-probe-ingress.yaml"
kubectl apply -f "$solution_directory/networkpolicy-shuttle-egress.yaml"
