#!/usr/bin/env bash
set -euo pipefail
test "$(kubectl config current-context)" = "kind-astro-ats-030-playground-010-02"
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

mkdir -p "$(dirname networkpolicy-shuttle-deny.yaml)"
cat > networkpolicy-shuttle-deny.yaml <<'CKAD_FILE_END'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: shuttle-egress
  namespace: starfleet
spec:
  podSelector:
    matchLabels:
      app: shuttle
  policyTypes:
  - Egress
  egress: []
CKAD_FILE_END
kubectl -n starfleet exec shuttle -- nslookup probe.starfleet.svc.cluster.local
wait_for_success kubectl -n starfleet exec shuttle -- wget -T 3 -qO- http://probe/
kubectl apply -f networkpolicy-shuttle-deny.yaml
CONNECTION_DENIED=0
for attempt in 1 2 3 4 5 6 7 8 9 10; do
  if kubectl -n starfleet exec shuttle -- wget -T 2 -qO- http://probe/ >/dev/null 2>&1; then sleep 1; else CONNECTION_DENIED=1; break; fi
done
test "$CONNECTION_DENIED" -eq 1
mkdir -p "$(dirname networkpolicy-shuttle-allow.yaml)"
cat > networkpolicy-shuttle-allow.yaml <<'CKAD_FILE_END'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: shuttle-egress
  namespace: starfleet
spec:
  podSelector:
    matchLabels:
      app: shuttle
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
      podSelector:
        matchLabels:
          k8s-app: kube-dns
    ports:
    - protocol: UDP
      port: 53
    - protocol: TCP
      port: 53
  - to:
    - podSelector:
        matchLabels:
          app: probe
    ports:
    - protocol: TCP
      port: 8080
CKAD_FILE_END
kubectl apply -f networkpolicy-shuttle-allow.yaml
kubectl -n starfleet get networkpolicy shuttle-egress -o yaml
kubectl -n starfleet exec shuttle -- nslookup probe.starfleet.svc.cluster.local
wait_for_success kubectl -n starfleet exec shuttle -- wget -T 3 -qO- http://probe/
kubectl -n kube-system get pods -l k8s-app=kube-dns --show-labels
kubectl -n starfleet exec shuttle -- wget -T 3 -qO- http://probe/ >/dev/null
printf 'ATS030/010/02: live practice checks passed\n'
