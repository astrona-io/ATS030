#!/usr/bin/env bash
set -euo pipefail
expected_context="kind-astro-ats-030-lab-020-02-01"
if [[ "$(kubectl config current-context)" != "$expected_context" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
kubectl -n starfleet get service probe -o json | python3 -c '
import json,sys
service=json.load(sys.stdin)
spec=service["spec"]
assert spec.get("type", "ClusterIP")=="ClusterIP", "Keep the internal Service type"
assert spec.get("selector")=={"app":"probe","release":"probe"}, "Preserve the required backend selection"
ports=spec.get("ports",[])
assert len(ports)==1, "Keep one application Service port"
assert ports[0]["port"]==80 and ports[0].get("protocol","TCP")=="TCP", "Clients must retain TCP port 80"
assert ports[0].get("targetPort") in ("http",8080), "Forward to the existing application listener"
'
kubectl -n starfleet get deployment probe -o json | python3 -c '
import json,sys
deployment=json.load(sys.stdin)
assert deployment["spec"].get("replicas")==2, "Preserve two application replicas"
assert deployment.get("status",{}).get("readyReplicas",0)>=2, "Both application replicas must be ready"
assert deployment.get("status",{}).get("availableReplicas",0)>=2, "Both application replicas must be available"
'
for attempt in 1 2 3 4 5 6 7 8 9 10; do
  if response="$(kubectl -n starfleet exec shuttle -- wget -q -T 3 -O- http://probe/)"; then
    if [[ "$response" == *"version=v1 host=probe-"* ]]; then
      printf 'Required Service fields, two ready replicas and client request verified\n'
      exit 0
    fi
  fi
  sleep 1
done
printf 'The original client did not receive the expected application response\n' >&2
exit 1
