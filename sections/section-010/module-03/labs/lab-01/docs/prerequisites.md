# Prerequisites

Use a host shell with `astrona`, `kubectl`, `jq` and a container engine that kind can use (Podman or Docker).

Select this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials that `kubectl` uses. This environment is separate from every playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-030-lab-010-03-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-030-lab-010-03-01" || exit 1
```
