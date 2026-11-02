#!/usr/bin/env bash
set -euo pipefail
test "$(kubectl config current-context)" = "kind-astro-ats-030-playground-030-02"
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
kubectl -n ingress-system port-forward service/traefik 18080:80 > traefik-port-forward.log 2>&1 &
PORT_FORWARD_PID=$!
wait_for_success curl --fail --silent --show-error --retry 10 --retry-connrefused --retry-delay 1 -H 'Host: probe.local' http://127.0.0.1:18080/
mkdir -p "$(dirname ingress-probe-broken.yaml)"
cat > ingress-probe-broken.yaml <<'CKAD_FILE_END'
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
            name: missing-service
            port:
              number: 80
CKAD_FILE_END
kubectl apply -f ingress-probe-broken.yaml
kubectl -n starfleet describe ingress probe
curl --silent --show-error -o /dev/null -w '%{http_code}\n' -H 'Host: probe.local' http://127.0.0.1:18080/
kubectl -n ingress-system logs deployment/traefik --tail=30
kubectl -n starfleet get service probe
kubectl apply -f ingress-probe.yaml
wait_for_success curl --fail --silent --show-error --retry 10 --retry-connrefused --retry-delay 1 -H 'Host: probe.local' http://127.0.0.1:18080/
kill "$PORT_FORWARD_PID"
test "$(kubectl -n starfleet get ingress probe -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}')" = probe
openssl req -x509 -newkey rsa:2048 -nodes -days 1 -keyout probe.key -out probe.crt -subj '/CN=probe.local' -addext 'subjectAltName=DNS:probe.local'
kubectl -n starfleet create secret tls probe-tls --cert=probe.crt --key=probe.key
cat > ingress-probe-tls.yaml <<'CKAD_FILE_END'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: probe
  namespace: starfleet
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
    traefik.ingress.kubernetes.io/router.tls: 'true'
spec:
  ingressClassName: traefik
  tls:
  - hosts:
    - probe.local
    secretName: probe-tls
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
kubectl apply -f ingress-probe-tls.yaml
kubectl -n ingress-system port-forward service/traefik 18443:443 > traefik-tls-forward.log 2>&1 &
PORT_FORWARD_PID=$!
wait_for_success curl --fail --silent --show-error --noproxy probe.local --cacert probe.crt --resolve probe.local:18443:127.0.0.1 https://probe.local:18443/
if curl --fail --silent --show-error --noproxy wrong.local --cacert probe.crt --resolve wrong.local:18443:127.0.0.1 https://wrong.local:18443/; then
  printf 'Unmatched certificate identity unexpectedly accepted\n' >&2
  exit 1
fi
kill "$PORT_FORWARD_PID"
printf 'ATS030/030/02: live practice checks passed\n'
