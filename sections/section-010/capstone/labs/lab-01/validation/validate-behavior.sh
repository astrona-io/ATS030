#!/usr/bin/env bash
# Check: live traffic. shuttle reaches probe, drifter and the drifter address are blocked.
set -uo pipefail
ready="$(kubectl -n starfleet get deployment probe -o jsonpath='{.status.readyReplicas}' 2>/dev/null)"
if [ "${ready:-0}" != "2" ]; then
  echo "FAIL: Deployment probe must keep 2 ready replicas"
  exit 1
fi
if ! kubectl -n starfleet exec shuttle -- wget -q -T 3 -O- http://probe/ 2>/dev/null | grep -q 'version=v1'; then
  echo "FAIL: shuttle does not receive version=v1 from probe (check egress and DNS)"
  exit 1
fi
if kubectl -n outpost exec drifter -- wget -q -T 3 -O- http://probe.starfleet/ 2>/dev/null | grep -q 'version='; then
  echo "FAIL: drifter still reaches probe"
  exit 1
fi
drifter_ip="$(kubectl -n outpost get pod drifter -o jsonpath='{.status.podIP}')"
message="$(kubectl -n starfleet exec shuttle -- wget -T 3 -O- "http://${drifter_ip}:8080/" 2>&1 || true)"
if ! echo "$message" | grep -qi 'timed out'; then
  echo "FAIL: shuttle must time out when it contacts the drifter address, but got: $message"
  exit 1
fi
echo "PASS: traffic matches the design"
