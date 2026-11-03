#!/usr/bin/env bash
# Check: probe-ingress allows only the shuttle pod of starfleet on TCP 8080.
set -uo pipefail
policy="$(kubectl -n starfleet get networkpolicy probe-ingress -o json 2>/dev/null)" || { echo "FAIL: NetworkPolicy probe-ingress not found in starfleet"; exit 1; }
if echo "$policy" | jq -e '
  (.spec.podSelector.matchLabels.app == "probe")
  and ((.spec.ingress | length) == 1)
  and ((.spec.ingress[0].from | length) == 1)
  and (.spec.ingress[0].from[0].podSelector.matchLabels.app == "shuttle")
  and (.spec.ingress[0].from[0] | has("namespaceSelector") | not)
  and (.spec.ingress[0].from[0] | has("ipBlock") | not)
  and ((.spec.ingress[0].ports | length) == 1)
  and (.spec.ingress[0].ports[0].port == 8080)' >/dev/null; then
  echo "PASS: probe-ingress allows only shuttle on 8080"
else
  echo "FAIL: probe-ingress must select app=probe and allow one peer, the pod app=shuttle in the same namespace, on port 8080"
  exit 1
fi
