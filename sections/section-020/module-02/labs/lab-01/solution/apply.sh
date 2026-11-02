#!/usr/bin/env bash
set -euo pipefail
expected_context="kind-astro-ats-030-lab-020-02-01"
if [[ "$(kubectl config current-context)" != "$expected_context" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
solution_directory="$(cd "$(dirname "$0")" && pwd)"
kubectl apply -f "$solution_directory/service-probe.yaml"
