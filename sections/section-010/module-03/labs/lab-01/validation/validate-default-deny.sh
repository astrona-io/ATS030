#!/usr/bin/env bash
# Check: default-deny-ingress selects every pod, isolates ingress and has no rules.
set -uo pipefail
policy="$(kubectl -n starfleet get networkpolicy default-deny-ingress -o json 2>/dev/null)" || { echo "FAIL: NetworkPolicy default-deny-ingress not found in starfleet"; exit 1; }
if echo "$policy" | jq -e '(.spec.podSelector == {}) and (.spec.policyTypes == ["Ingress"]) and ((.spec.ingress // []) | length == 0)' >/dev/null; then
  echo "PASS: default-deny-ingress isolates every pod and allows nothing"
else
  echo "FAIL: default-deny-ingress must have an empty podSelector, policyTypes [Ingress] and no ingress rules"
  exit 1
fi
