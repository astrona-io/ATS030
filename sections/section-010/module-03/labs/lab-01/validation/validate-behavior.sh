#!/usr/bin/env bash
# Check: live traffic. drifter gets a reply, shuttle times out, probe stays ready.
set -uo pipefail
ready="$(kubectl -n starfleet get deployment probe -o jsonpath='{.status.readyReplicas}' 2>/dev/null)"
if [ "${ready:-0}" != "2" ]; then
  echo "FAIL: Deployment probe must keep 2 ready replicas"
  exit 1
fi
if ! kubectl -n outpost exec drifter -- wget -q -T 3 -O- http://probe.starfleet/ 2>/dev/null | grep -q 'version=v1'; then
  echo "FAIL: drifter in outpost does not receive version=v1 from probe"
  exit 1
fi
if out="$(kubectl -n starfleet exec shuttle -- wget -q -T 3 -O- http://probe/ 2>/dev/null)" && echo "$out" | grep -q 'version='; then
  echo "FAIL: shuttle still reaches probe"
  exit 1
fi
echo "PASS: drifter reaches probe and shuttle is blocked"
