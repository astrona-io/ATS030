#!/usr/bin/env bash
set -euo pipefail
test "$(kubectl config current-context)" = "kind-astro-ats-030-playground-030-01"
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

mkdir -p "$(dirname ingress-probe.yaml)"
cat > ingress-probe.yaml <<'CKAD_FILE_END'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: probe
  namespace: starfleet
spec:
  ingressClassName: traefik
  rules:
  - host: probe.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: probe
            port:
              number: 80
CKAD_FILE_END
kubectl apply -f ingress-probe.yaml
kubectl -n starfleet get ingress probe -o yaml
kubectl get ingressclass traefik
kubectl -n ingress-system port-forward service/traefik 18080:80 > traefik-port-forward.log 2>&1 &
PORT_FORWARD_PID=$!
wait_for_success curl --fail --silent --show-error --retry 10 --retry-connrefused --retry-delay 1 -H 'Host: probe.local' http://127.0.0.1:18080/
kubectl -n ingress-system logs deployment/traefik --tail=20
curl --silent --show-error -o /dev/null -w '%{http_code}\n' -H 'Host: unmatched.local' http://127.0.0.1:18080/
kill "$PORT_FORWARD_PID"
test "$(kubectl -n starfleet get ingress probe -o jsonpath='{.spec.ingressClassName}')" = traefik
printf 'ATS030/030/01: live practice checks passed\n'
