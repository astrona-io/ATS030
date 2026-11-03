#!/usr/bin/env bash
# Check: Services and Deployments keep their original shape.
set -uo pipefail
probe="$(kubectl -n starfleet get service probe -o json 2>/dev/null)" || { echo "FAIL: Service probe missing"; exit 1; }
docs="$(kubectl -n starfleet get service docs -o json 2>/dev/null)" || { echo "FAIL: Service docs missing"; exit 1; }
echo "$probe" | jq -e '(.spec.selector == {"app":"probe","release":"probe"}) and (.spec.ports[0].port == 80)' >/dev/null || { echo "FAIL: Service probe was changed"; exit 1; }
echo "$docs" | jq -e '(.spec.selector == {"app":"docs"}) and (.spec.ports[0].port == 80)' >/dev/null || { echo "FAIL: Service docs was changed"; exit 1; }
[ "$(kubectl -n starfleet get deployment probe -o jsonpath='{.status.readyReplicas}')" = "2" ] || { echo "FAIL: Deployment probe must keep 2 ready replicas"; exit 1; }
[ "$(kubectl -n starfleet get deployment docs -o jsonpath='{.status.readyReplicas}')" = "1" ] || { echo "FAIL: Deployment docs must keep 1 ready replica"; exit 1; }
echo "PASS: Services and Deployments are unchanged"
