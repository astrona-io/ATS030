#!/usr/bin/env bash
# Check: the Ingress portal has the class, host, both paths, the TLS Secret and the Traefik annotations.
set -uo pipefail
ing="$(kubectl -n starfleet get ingress portal -o json 2>/dev/null)" || { echo "FAIL: Ingress portal not found in starfleet"; exit 1; }
if echo "$ing" | jq -e '
  (.spec.ingressClassName == "traefik")
  and (.metadata.annotations["traefik.ingress.kubernetes.io/router.entrypoints"] == "websecure")
  and (.metadata.annotations["traefik.ingress.kubernetes.io/router.tls"] == "true")
  and (.spec.rules | length == 1)
  and (.spec.rules[0].host == "portal.local")
  and ([.spec.rules[0].http.paths[] | select(.path == "/" and .pathType == "Prefix" and .backend.service.name == "probe" and .backend.service.port.number == 80)] | length == 1)
  and ([.spec.rules[0].http.paths[] | select(.path == "/docs" and .pathType == "Prefix" and .backend.service.name == "docs" and .backend.service.port.number == 80)] | length == 1)
  and (.spec.tls | length == 1)
  and (.spec.tls[0].secretName == "portal-tls")
  and (.spec.tls[0].hosts == ["portal.local"])' >/dev/null; then
  echo "PASS: Ingress portal has the required class, rules and TLS"
else
  echo "FAIL: Ingress portal does not match the required class, host, paths, TLS Secret and annotations"
  exit 1
fi
