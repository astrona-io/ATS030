#!/usr/bin/env bash
set -euo pipefail
expected_context="kind-astro-ats-030-lab-020-02-01"
if [[ "$(kubectl config current-context)" != "$expected_context" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
bootstrap_directory="$(cd "$(dirname "$0")" && pwd)"
kubectl apply -f "$bootstrap_directory/manifests/start.yaml"
kubectl -n starfleet rollout status deployment/probe --timeout=180s
kubectl -n starfleet wait --for=condition=Ready pod/shuttle --timeout=120s
kubectl -n starfleet exec shuttle -- nslookup probe >/dev/null
backend_address="$(kubectl -n starfleet get pods -l app=probe -o jsonpath='{.items[0].status.podIP}')"
kubectl -n starfleet exec shuttle -- wget -q -T 3 -O- "http://$backend_address:8080/" >/dev/null
if kubectl -n starfleet exec shuttle -- wget -q -T 3 -O- http://probe/ >/dev/null 2>&1; then
  printf 'Starting fault was not established: Service request unexpectedly succeeded\n' >&2
  exit 1
fi
