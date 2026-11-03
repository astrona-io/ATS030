#!/usr/bin/env bash
# Check: live behavior. drifter reaches probe through the alias and the headless name lists both pods.
set -uo pipefail
ready="$(kubectl -n starfleet get deployment probe -o jsonpath='{.status.readyReplicas}' 2>/dev/null)"
if [ "${ready:-0}" != "2" ]; then
  echo "FAIL: Deployment probe must keep 2 ready replicas"
  exit 1
fi
if ! kubectl -n outpost exec drifter -- wget -q -T 3 -O- http://probe-alias/ 2>/dev/null | grep -q 'version=v1'; then
  echo "FAIL: drifter does not receive version=v1 from http://probe-alias/"
  exit 1
fi
lookup="$(kubectl -n starfleet exec shuttle -- nslookup probe-pods.starfleet.svc.cluster.local 2>/dev/null)"
for ip in $(kubectl -n starfleet get pods -l app=probe -o jsonpath='{.items[*].status.podIP}'); do
  if ! echo "$lookup" | grep -q "$ip"; then
    echo "FAIL: probe-pods does not resolve to pod address $ip"
    exit 1
  fi
done
echo "PASS: alias reaches probe and probe-pods resolves to every pod"
