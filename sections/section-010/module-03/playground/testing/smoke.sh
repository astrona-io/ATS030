#!/usr/bin/env bash
set -euo pipefail
test "$(kubectl config current-context)" = "kind-astro-ats-030-playground-010-03"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
cd "$work"
kubectl -n starfleet exec shuttle -- wget -q -T 3 -O- http://probe/
kubectl -n outpost exec drifter -- wget -q -T 3 -O- http://probe.starfleet/
cat > default-deny-ingress.yaml <<'Y'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: starfleet
spec:
  podSelector: {}
  policyTypes:
  - Ingress
Y
cat > networkpolicy-probe-from-drifter.yaml <<'Y'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: probe-from-drifter
  namespace: starfleet
spec:
  podSelector:
    matchLabels:
      app: probe
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: outpost
      podSelector:
        matchLabels:
          app: drifter
    ports:
    - protocol: TCP
      port: 8080
Y
kubectl apply -f default-deny-ingress.yaml
sleep 5
if kubectl -n starfleet exec shuttle -- wget -q -T 3 -O- http://probe/; then echo "shuttle should be blocked" >&2; exit 1; fi
kubectl apply -f networkpolicy-probe-from-drifter.yaml
for attempt in 1 2 3 4 5 6 7 8 9 10; do
  if kubectl -n outpost exec drifter -- wget -q -T 3 -O- http://probe.starfleet/; then break; fi
  sleep 2
done
kubectl -n outpost exec drifter -- wget -q -T 3 -O- http://probe.starfleet/
if kubectl -n starfleet exec shuttle -- wget -q -T 3 -O- http://probe/; then echo "shuttle should be blocked" >&2; exit 1; fi
printf 'ATS030/010/03: practice checks passed\n'
