#!/usr/bin/env bash
# Check: probe-pods is headless and selects the probe pods.
set -uo pipefail
svc="$(kubectl -n starfleet get service probe-pods -o json 2>/dev/null)" || { echo "FAIL: Service probe-pods not found in starfleet"; exit 1; }
if echo "$svc" | jq -e '(.spec.clusterIP == "None") and (.spec.selector == {"app":"probe"})' >/dev/null; then
  echo "PASS: probe-pods is headless and selects app=probe"
else
  echo "FAIL: probe-pods needs clusterIP None and selector app=probe"
  exit 1
fi
