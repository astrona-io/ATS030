#!/usr/bin/env bash
set -euo pipefail
test "$(kubectl config current-context)" = "kind-astro-ats-030-playground-010-01"
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

mkdir -p "$(dirname networkpolicy-probe-deny.yaml)"
cat > networkpolicy-probe-deny.yaml <<'CKAD_FILE_END'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: probe-deny
  namespace: starfleet
spec:
  podSelector:
    matchLabels:
      app: probe
  policyTypes:
  - Ingress
  ingress: []
CKAD_FILE_END
wait_for_success kubectl -n starfleet exec shuttle -- wget -T 3 -qO- http://probe/
kubectl apply -f networkpolicy-probe-deny.yaml
CONNECTION_DENIED=0
for attempt in 1 2 3 4 5 6 7 8 9 10; do
  if kubectl -n starfleet exec shuttle -- wget -T 2 -qO- http://probe/ >/dev/null 2>&1; then sleep 1; else CONNECTION_DENIED=1; break; fi
done
test "$CONNECTION_DENIED" -eq 1
mkdir -p "$(dirname networkpolicy-probe-shuttle.yaml)"
cat > networkpolicy-probe-shuttle.yaml <<'CKAD_FILE_END'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: probe-shuttle
  namespace: starfleet
spec:
  podSelector:
    matchLabels:
      app: probe
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: shuttle
    ports:
    - protocol: TCP
      port: 8080
CKAD_FILE_END
kubectl apply -f networkpolicy-probe-shuttle.yaml
wait_for_success kubectl -n starfleet exec shuttle -- wget -T 3 -qO- http://probe/
kubectl -n starfleet get networkpolicy -o yaml
CONNECTION_DENIED=0
for attempt in 1 2 3 4 5 6 7 8 9 10; do
  if kubectl -n outpost exec drifter -- wget -T 2 -qO- http://probe.starfleet/ >/dev/null 2>&1; then sleep 1; else CONNECTION_DENIED=1; break; fi
done
test "$CONNECTION_DENIED" -eq 1
kubectl -n starfleet get pods --show-labels
kubectl -n outpost get pods --show-labels
kubectl -n starfleet exec shuttle -- wget -T 3 -qO- http://probe/ >/dev/null
printf 'ATS030/010/01: live practice checks passed\n'
