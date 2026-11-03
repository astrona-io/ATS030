#!/usr/bin/env bash
# Check: allow-everything is deleted and no policy still allows every source.
set -uo pipefail
if kubectl -n starfleet get networkpolicy allow-everything >/dev/null 2>&1; then
  echo "FAIL: NetworkPolicy allow-everything still exists"
  exit 1
fi
open="$(kubectl -n starfleet get networkpolicy -o json | jq -r '.items[] | select(any(.spec.ingress[]?; (has("from") | not) and (has("ports") | not))) | .metadata.name')"
if [ -n "$open" ]; then
  echo "FAIL: these policies still allow every ingress source: $open"
  exit 1
fi
echo "PASS: no policy allows every ingress source"
