---
draft: true
exam_objectives:
- Use Ingress rules to expose applications
---
# Locate A Broken Ingress Backend Reference

You will establish a working external request path, then point the Ingress at an absent Service. The client and controller remain reachable while the backend contract fails. This makes it possible to distinguish routing, Service identity and application readiness instead of treating every unsuccessful response as a network outage.

Use the module playground and its private kubeconfig. The context check below prevents commands from being directed at an unrelated cluster. The helper retries a command for a bounded interval after controller or policy changes; it cannot turn a persistent failure into success. Read the actual errors when the interval expires.

<!-- astrona:playground:renew -->

For a timed catalog session, renew this module before continuing. Skip renewal for an untimed local author run:

```sh
astrona run renew astrona-io/ATS030/section-030/module-02/playground
```

Select the module environment and define a bounded retry helper:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-030-playground-030-02)"
test "$(kubectl config current-context)" = "kind-astro-ats-030-playground-030-02"
kubectl -n starfleet get pods
wait_for_success() {
  for attempt in 1 2 3 4 5 6 7 8 9 10; do
    if "$@"; then return 0; fi
    sleep 1
  done
  return 1
}
```

Save the correct route and create a loopback forward to the controller.

Save this as `ingress-probe.yaml`:

```yaml
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
```

Apply or use the saved input, then check the result:

```sh
kubectl apply -f ingress-probe.yaml
kubectl -n ingress-system port-forward service/traefik 18080:80 > traefik-port-forward.log 2>&1 &
PORT_FORWARD_PID=$!
wait_for_success curl --fail --silent --show-error --retry 10 --retry-connrefused --retry-delay 1 -H 'Host: probe.local' http://127.0.0.1:18080/
```

Verify the initial response before injecting the failure. Without a baseline, a later failed request could arise from an unrelated controller or local-port problem.

Save an Ingress with a wrong backend Service name and inspect the resulting evidence.

Save this as `ingress-probe-broken.yaml`:

```yaml
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
```

Apply or use the saved input, then check the result:

```sh
kubectl apply -f ingress-probe-broken.yaml
kubectl -n starfleet describe ingress probe
curl --silent --show-error -o /dev/null -w '%{http_code}\n' -H 'Host: probe.local' http://127.0.0.1:18080/
kubectl -n ingress-system logs deployment/traefik --tail=30
kubectl -n starfleet get service probe
```

The valid probe Service still exists, but the route names another target. Controller responses and logs can vary during propagation, so identify the referenced name and observed condition rather than memorizing a single status code.

Restore the complete correct route, retry a fresh request and clean up the forward.

```sh
kubectl apply -f ingress-probe.yaml
wait_for_success curl --fail --silent --show-error --retry 10 --retry-connrefused --retry-delay 1 -H 'Host: probe.local' http://127.0.0.1:18080/
kill "$PORT_FORWARD_PID"
```

The repaired response should identify the practice application. Rebuilding its image would not have repaired the wrong Service name.

External diagnosis follows the specific request through each boundary. A reachable controller can still have no usable route or backend. TLS certificate verification is another client boundary and should never be hidden by treating a disabled verification flag as a universal repair.

A Transport Layer Security (TLS) connection adds a certificate identity contract to routing. Create a disposable one-day certificate with a Subject Alternative Name matching probe.local. This certificate is for this isolated exercise, and its key must not be reused for a production identity.

```sh
openssl req -x509 -newkey rsa:2048 -nodes -days 1 -keyout probe.key -out probe.crt -subj '/CN=probe.local' -addext 'subjectAltName=DNS:probe.local'
kubectl -n starfleet create secret tls probe-tls --cert=probe.crt --key=probe.key
```

Save this as `ingress-probe-tls.yaml`:

```yaml
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
```

Apply it and start a separate loopback HTTPS forward. The trusted certificate file establishes this exercise's trust, while the hostname must still match the certificate. The negative check deliberately uses a different hostname and expects certificate verification to fail.

```sh
kubectl apply -f ingress-probe-tls.yaml
kubectl -n ingress-system port-forward service/traefik 18443:443 > traefik-tls-forward.log 2>&1 &
PORT_FORWARD_PID=$!
wait_for_success curl --fail --silent --show-error --noproxy probe.local --cacert probe.crt --resolve probe.local:18443:127.0.0.1 https://probe.local:18443/
if curl --fail --silent --show-error --noproxy wrong.local --cacert probe.crt --resolve wrong.local:18443:127.0.0.1 https://wrong.local:18443/; then
  printf 'Unmatched certificate identity unexpectedly accepted\n' >&2
  exit 1
fi
kill "$PORT_FORWARD_PID"
```

The HTTPS route terminates at Traefik. The backend hop still uses the separate HTTP Service contract; frontend TLS does not automatically encrypt that hop. The certificate-verified request and rejected hostname test supply distinct identity evidence. Remove the disposable local key when you finish, and keep verification enabled rather than using an insecure flag to hide a mismatch.

## Common pitfalls

> [!WARNING]
> Keep the selected module context and inspect the observed outcome. Resource acceptance does not establish readiness or a successful request. Reset this isolated environment if earlier experiments changed the required starting state.
