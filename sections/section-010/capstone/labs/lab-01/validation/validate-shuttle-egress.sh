#!/usr/bin/env bash
# Check: shuttle-egress allows probe on 8080 and DNS in kube-system, nothing else.
set -uo pipefail
policy="$(kubectl -n starfleet get networkpolicy shuttle-egress -o json 2>/dev/null)" || { echo "FAIL: NetworkPolicy shuttle-egress not found in starfleet"; exit 1; }
if echo "$policy" | jq -e '
  (.spec.podSelector.matchLabels.app == "shuttle")
  and (.spec.policyTypes == ["Egress"])
  and ((.spec.egress | length) == 2)
  and any(.spec.egress[]; any(.to[]?; .podSelector.matchLabels.app == "probe") and any(.ports[]?; .port == 8080))
  and any(.spec.egress[]; any(.to[]?; .namespaceSelector.matchLabels["kubernetes.io/metadata.name"] == "kube-system")
        and any(.ports[]?; .port == 53 and ((.protocol // "TCP") == "UDP"))
        and any(.ports[]?; .port == 53 and ((.protocol // "TCP") == "TCP")))' >/dev/null; then
  echo "PASS: shuttle-egress allows probe on 8080 and DNS only"
else
  echo "FAIL: shuttle-egress must select app=shuttle, list only Egress, and hold two rules: app=probe on 8080, and kube-system on port 53 for UDP and TCP"
  exit 1
fi
