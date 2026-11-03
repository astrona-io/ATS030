#!/usr/bin/env bash
# Check: probe-from-drifter allows only drifter of namespace outpost, on TCP 8080, with AND semantics.
set -uo pipefail
policy="$(kubectl -n starfleet get networkpolicy probe-from-drifter -o json 2>/dev/null)" || { echo "FAIL: NetworkPolicy probe-from-drifter not found in starfleet"; exit 1; }
if echo "$policy" | jq -e '
  (.spec.podSelector.matchLabels.app == "probe")
  and ((.spec.policyTypes // ["Ingress"]) | index("Ingress") != null)
  and ((.spec.ingress | length) == 1)
  and ((.spec.ingress[0].from | length) == 1)
  and (.spec.ingress[0].from[0].namespaceSelector.matchLabels["kubernetes.io/metadata.name"] == "outpost")
  and (.spec.ingress[0].from[0].podSelector.matchLabels.app == "drifter")
  and ((.spec.ingress[0].ports | length) == 1)
  and (.spec.ingress[0].ports[0].port == 8080)
  and ((.spec.ingress[0].ports[0].protocol // "TCP") == "TCP")' >/dev/null; then
  echo "PASS: probe-from-drifter allows one peer entry with both selectors on TCP 8080"
else
  echo "FAIL: probe-from-drifter must select app=probe and have one from entry holding both the namespaceSelector (outpost) and the podSelector (app=drifter), with port 8080"
  exit 1
fi
