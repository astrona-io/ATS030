# Default Deny, Peer Selectors And IP Blocks Environment

This ungraded playground provides an isolated kind cluster running Kubernetes v1.35.0. It uses its own kubeconfig. The namespace `starfleet` contains the `probe` Deployment with two Pods, the `probe` Service on port 80 and the `shuttle` client Pod. The namespace `outpost` contains the `drifter` client Pod. The playground starts with no NetworkPolicy, so every client can reach every pod. No task is submitted for grading.

The `probe` container listens on port 8080 and the Service receives port 80. The application code is supplied through the `probe-code` ConfigMap. It answers every path with a line such as `version=v1 host=<pod> greeting=hello`.

Select the private kubeconfig before application commands:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-030-playground-010-03)"
kubectl config current-context
kubectl -n starfleet get pods
```

The context must be `kind-astro-ats-030-playground-010-03`. If it differs, stop and select the module environment. Images need network access during first preparation. Local node storage is temporary and does not survive playground destruction.

Destroy and start the module again for a clean reset. For manual cleanup:

```sh
astrona destroy ats-030-playground-010-03
```
