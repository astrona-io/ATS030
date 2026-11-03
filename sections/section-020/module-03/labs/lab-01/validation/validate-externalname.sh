#!/usr/bin/env bash
# Check: probe-alias in outpost is an ExternalName Service.
set -uo pipefail
svc="$(kubectl -n outpost get service probe-alias -o json 2>/dev/null)" || { echo "FAIL: Service probe-alias not found in outpost"; exit 1; }
if echo "$svc" | jq -e '(.spec.type == "ExternalName") and (.spec.externalName == "probe.starfleet.svc.cluster.local")' >/dev/null; then
  echo "PASS: probe-alias is an ExternalName Service for the probe Service"
else
  echo "FAIL: probe-alias needs type ExternalName and externalName probe.starfleet.svc.cluster.local"
  exit 1
fi
