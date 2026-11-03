# Service Types, Headless Services And Service DNS Playground

Ungraded module environment: ats-030-playground-020-03. Kubernetes v1.35.0 is pinned by node image digest. Bootstrap writes only to the expected isolated context. No validation block is registered in config.yaml. UNTESTED: this playground was built from static checks only and has not been started.

```sh
astrona validate -c .
astrona run -c .
astrona destroy ats-030-playground-020-03
```

The author smoke script replays the practical commands of the module readings. Run it only after the playground starts, with its private kubeconfig.

```sh
KUBECONFIG="$(astrona kubeconfig ats-030-playground-020-03)" bash testing/smoke.sh
```
