#!/usr/bin/env bash
# Check: probe-node is a NodePort Service on 30081 for the probe pods.
set -uo pipefail
svc="$(kubectl -n starfleet get service probe-node -o json 2>/dev/null)" || { echo "FAIL: Service probe-node not found in starfleet"; exit 1; }
if echo "$svc" | jq -e '(.spec.type == "NodePort") and (.spec.selector == {"app":"probe"}) and (.spec.ports | length == 1) and (.spec.ports[0].port == 80) and (.spec.ports[0].nodePort == 30081) and (.spec.ports[0].targetPort == "http" or .spec.ports[0].targetPort == 8080)' >/dev/null; then
  echo "PASS: probe-node is a NodePort Service on 30081"
else
  echo "FAIL: probe-node needs type NodePort, selector app=probe, port 80, targetPort http and nodePort 30081"
  exit 1
fi
