---
draft: true
exam_objectives:
- Use Ingress rules to expose applications
---
# Route A Host And Path Through An Ingress Controller

This playground installs Traefik as an Ingress controller. The application Service exists independently. You will create a networking.k8s.io/v1 Ingress, forward the controller entry point to a loopback port and send a request with the matching host. The controller is required; the Ingress object alone cannot forward traffic.

Use the module playground and its private kubeconfig. The context check below prevents commands from being directed at an unrelated cluster. The helper retries a command for a bounded interval after controller or policy changes; it cannot turn a persistent failure into success. Read the actual errors when the interval expires.

<!-- astrona:playground:renew -->

For a timed catalog session, renew this module before continuing. Skip renewal for an untimed local author run:

```sh
astrona run renew astrona-io/ATS030/section-030/module-01/playground
```

Select the module environment and define a bounded retry helper:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-030-playground-030-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-030-playground-030-01"
kubectl -n starfleet get pods
wait_for_success() {
  for attempt in 1 2 3 4 5 6 7 8 9 10; do
    if "$@"; then return 0; fi
    sleep 1
  done
  return 1
}
```

Save the complete Ingress with an explicit class, host, path and Service port.

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
kubectl -n starfleet get ingress probe -o yaml
kubectl get ingressclass traefik
```

The backend port is the Service port 80, not the container port 8080. The class determines which controller should interpret the declaration.

Start a background loopback-only port forward to the controller Service. Use an unused local port and keep its process identity so cleanup is explicit.

```sh
kubectl -n ingress-system port-forward service/traefik 18080:80 > traefik-port-forward.log 2>&1 &
PORT_FORWARD_PID=$!
wait_for_success curl --fail --silent --show-error --retry 10 --retry-connrefused --retry-delay 1 -H 'Host: probe.local' http://127.0.0.1:18080/
```

The Host header selects the declared virtual host. A request to the same socket with a different host can follow a different route. A successful response establishes this selected request, not every possible external path.

Inspect controller evidence and compare an unmatched host, then stop the local forward.

```sh
kubectl -n ingress-system logs deployment/traefik --tail=20
curl --silent --show-error -o /dev/null -w '%{http_code}\n' -H 'Host: unmatched.local' http://127.0.0.1:18080/
kill "$PORT_FORWARD_PID"
```

An unmatched request should not be interpreted as an application failure for the matched route. The exact response is controller behavior that you inspect rather than assume from resource creation.

Keep client socket, host match, path match, controller, Service and ready backend separate. The local port forward is a practice access path, not a production load balancer. TLS termination and certificate identity have additional contracts addressed by explicit configuration.

## Common pitfalls

> [!WARNING]
> Keep the selected module context and inspect the observed outcome. Resource acceptance does not establish readiness or a successful request. Reset this isolated environment if earlier experiments changed the required starting state.
