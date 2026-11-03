#!/usr/bin/env bash
# Check: default-deny-all selects every pod and isolates both directions with no rules.
set -uo pipefail
policy="$(kubectl -n starfleet get networkpolicy default-deny-all -o json 2>/dev/null)" || { echo "FAIL: NetworkPolicy default-deny-all not found in starfleet"; exit 1; }
if echo "$policy" | jq -e '(.spec.podSelector == {}) and ((.spec.policyTypes | sort) == ["Egress","Ingress"]) and ((.spec.ingress // []) | length == 0) and ((.spec.egress // []) | length == 0)' >/dev/null; then
  echo "PASS: default-deny-all closes both directions"
else
  echo "FAIL: default-deny-all needs an empty podSelector, policyTypes Ingress and Egress, and no rules"
  exit 1
fi
