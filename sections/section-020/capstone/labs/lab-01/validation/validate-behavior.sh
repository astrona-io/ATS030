#!/usr/bin/env bash
# Check: live behavior. Both clients reach probe and the headless name lists every pod.
set -uo pipefail
ready="$(kubectl -n starfleet get deployment probe -o jsonpath='{.status.readyReplicas}' 2>/dev/null)"
if [ "${ready:-0}" != "2" ]; then
  echo "FAIL: Deployment probe must keep 2 ready replicas"
  exit 1
fi
if ! kubectl -n starfleet exec shuttle -- wget -q -T 3 -O- http://probe/ 2>/dev/null | grep -q 'version=v1'; then
  echo "FAIL: shuttle does not receive version=v1 from http://probe/"
  exit 1
fi
if ! kubectl -n outpost exec drifter -- wget -q -T 3 -O- http://probe/ 2>/dev/null | grep -q 'version=v1'; then
  echo "FAIL: drifter does not receive version=v1 from http://probe/"
  exit 1
fi
lookup="$(kubectl -n starfleet exec shuttle -- nslookup probe-pods.starfleet.svc.cluster.local 2>/dev/null)"
for ip in $(kubectl -n starfleet get pods -l app=probe -o jsonpath='{.items[*].status.podIP}'); do
  if ! echo "$lookup" | grep -q "$ip"; then
    echo "FAIL: probe-pods does not resolve to pod address $ip"
    exit 1
  fi
done
echo "PASS: both clients reach probe and probe-pods resolves to every pod"
