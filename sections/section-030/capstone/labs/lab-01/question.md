---
draft: true
exam_objectives:
- Use Ingress rules to expose applications
---
# Publish Two Services Through One TLS Ingress

The application has two backends, `probe` and `docs`. Publish both under one host with HTTPS through the Traefik Ingress controller.

## Starting state

The lab includes a working Traefik Ingress controller with the IngressClass `traefik`. The Services `probe` (answers `version=v1`) and `docs` (answers `version=v2`) run in `starfleet` on port 80. The TLS Secret `portal-tls` exists in `starfleet` and holds a certificate for the name `portal.local`. No Ingress exists.

Use a host shell with this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials that `kubectl` uses.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-030-capstone-030)"
test "$(kubectl config current-context)" = "kind-astro-ats-030-capstone-030" || exit 1
```

## Required result

1. Create the Ingress `portal` in `starfleet` with the class `traefik`.
2. The host `portal.local` routes the Prefix path `/` to the Service `probe` port 80 and the Prefix path `/docs` to the Service `docs` port 80.
3. Terminate TLS with the Secret `portal-tls` for the host `portal.local`. Use the annotations `traefik.ingress.kubernetes.io/router.entrypoints: websecure` and `traefik.ingress.kubernetes.io/router.tls: 'true'`.
4. Do not change the Services or the Deployments.

A client that trusts the supplied certificate must receive `version=v1` for `/` and `version=v2` for `/docs/guide`. It must reject the server name `wrong.local`. A request for another host name must return 404.

## Verify The Result

Check `kubectl -n starfleet describe ingress portal` for both backends. Wait a few seconds for the controller, then submit.
