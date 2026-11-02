#!/usr/bin/env bash
set -euo pipefail
test "$(kubectl config current-context)" = "kind-astro-ats-030-playground-020-02"
practice_directory="$(mktemp -d)"
cleanup() {
  if [[ -n "${PORT_FORWARD_PID:-}" ]]; then kill "$PORT_FORWARD_PID" 2>/dev/null || true; fi
  rm -rf "$practice_directory"
}
trap cleanup EXIT
cd "$practice_directory"
wait_for_success() {
  for attempt in 1 2 3 4 5 6 7 8 9 10; do
    if "$@"; then return 0; fi
    sleep 1
  done
  return 1
}

wait_for_success kubectl -n starfleet exec shuttle -- wget -T 3 -qO- http://probe/
kubectl -n starfleet patch service probe --type=json -p '[{"op":"replace","path":"/spec/selector","value":{"app":"absent"}}]'
kubectl -n starfleet get service probe -o yaml
kubectl -n starfleet get pods --show-labels
kubectl -n starfleet get endpointslice -l kubernetes.io/service-name=probe -o yaml
CONNECTION_DENIED=0
for attempt in 1 2 3 4 5 6 7 8 9 10; do
  if kubectl -n starfleet exec shuttle -- wget -T 2 -qO- http://probe/ >/dev/null 2>&1; then sleep 1; else CONNECTION_DENIED=1; break; fi
done
test "$CONNECTION_DENIED" -eq 1
kubectl -n starfleet patch service probe --type=json -p '[{"op":"replace","path":"/spec/selector","value":{"app":"probe","release":"probe"}}]'
wait_for_success kubectl -n starfleet exec shuttle -- wget -T 3 -qO- http://probe/
kubectl -n starfleet exec shuttle -- wget -T 3 -qO- http://probe/ >/dev/null
printf 'ATS030/020/02: live practice checks passed\n'
