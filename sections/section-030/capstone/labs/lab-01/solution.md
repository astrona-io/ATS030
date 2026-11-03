---
draft: true
exam_objectives:
- Use Ingress rules to expose applications
---
# Publish Two Services Through One TLS Ingress Solution

Select the lab's private kubeconfig:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-030-capstone-030)"
test "$(kubectl config current-context)" = "kind-astro-ats-030-capstone-030" || exit 1
```

## Inspect the starting state

Confirm that the controller class, both Services and the TLS Secret exist.

```sh
kubectl get ingressclass
kubectl -n starfleet get service probe docs
kubectl -n starfleet get secret portal-tls
kubectl -n starfleet get endpointslices
```

The IngressClass `traefik` is handled by the controller in `ingress-system`. Both Services expose port 80, and each has ready endpoints. The Ingress refers to the Service port, not to the container port.

## Write the Ingress

Save this as `ingress-portal.yaml`. One host holds two path rules. Traefik chooses the rule with the longest matching path, so `/docs/guide` goes to `docs` and every other path goes to `probe`. The `tls` block names the Secret that holds the certificate and key for the host.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: portal
  namespace: starfleet
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
    traefik.ingress.kubernetes.io/router.tls: 'true'
spec:
  ingressClassName: traefik
  rules:
  - host: portal.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: probe
            port:
              number: 80
      - path: /docs
        pathType: Prefix
        backend:
          service:
            name: docs
            port:
              number: 80
  tls:
  - hosts:
    - portal.local
    secretName: portal-tls
```

```sh
kubectl apply -f ingress-portal.yaml
kubectl -n starfleet describe ingress portal
```

The `Rules` section lists both paths with the backend endpoints of each Service.

## Verify the result

Wait a few seconds for the controller to load the route. The grader checks the Ingress fields and sends HTTPS requests through the controller. Submit with `astrona submit`, then remove the lab with `astrona destroy ats-030-capstone-030`.

## Common pitfalls

> [!WARNING]
> A `tls` host that differs from the rule host does not match the request. A backend must name the Service port (80), not the container port. A rule without a host matches every host name and breaks the 404 check.
