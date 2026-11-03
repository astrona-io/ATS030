#!/usr/bin/env bash
# Check: probe in outpost is an ExternalName Service for the probe Service of starfleet.
set -uo pipefail
svc="$(kubectl -n outpost get service probe -o json 2>/dev/null)" || { echo "FAIL: Service probe not found in outpost"; exit 1; }
if echo "$svc" | jq -e '(.spec.type == "ExternalName") and (.spec.externalName == "probe.starfleet.svc.cluster.local")' >/dev/null; then
  echo "PASS: probe in outpost is an ExternalName Service"
else
  echo "FAIL: probe in outpost needs type ExternalName and externalName probe.starfleet.svc.cluster.local"
  exit 1
fi
