#!/usr/bin/env bash
# Check: probe in starfleet selects the pods, maps port 80 to the named port and has ready endpoints.
set -uo pipefail
svc="$(kubectl -n starfleet get service probe -o json 2>/dev/null)" || { echo "FAIL: Service probe not found in starfleet"; exit 1; }
if ! echo "$svc" | jq -e '(.spec.type // "ClusterIP") == "ClusterIP" and (.spec.selector == {"app":"probe","release":"probe"}) and (.spec.ports | length == 1) and (.spec.ports[0].port == 80) and (.spec.ports[0].targetPort == "http" or .spec.ports[0].targetPort == 8080)' >/dev/null; then
  echo "FAIL: probe needs selector app=probe and release=probe, port 80 and targetPort http"
  exit 1
fi
ready="$(kubectl -n starfleet get endpointslices -l kubernetes.io/service-name=probe -o json | jq '[.items[].endpoints[]? | select(.conditions.ready == true)] | length')"
if [ "${ready:-0}" -ge 2 ]; then
  echo "PASS: probe has $ready ready endpoints"
else
  echo "FAIL: probe has fewer than 2 ready endpoints"
  exit 1
fi
