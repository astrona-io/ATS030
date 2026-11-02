---
draft: true
exam_objectives:
- Provide and troubleshoot access to applications via services
---
# Trace A Missing Backend To Its Selector

You will change the Service selector to a label that no application Pod has. The workload remains available, but the Service loses its intended backend population. Diagnosis should follow the selector and EndpointSlices rather than rebuilding an otherwise healthy image.

Use the module playground and its private kubeconfig. The context check below prevents commands from being directed at an unrelated cluster. The helper retries a command for a bounded interval after controller or policy changes; it cannot turn a persistent failure into success. Read the actual errors when the interval expires.

Changing the selector and changing the target port create different defects. One can remove the intended backend population; the other can preserve endpoints while targeting an absent listener. Read the relevant evidence before correcting each case.

Verify through the original Pod caller after restoring the intended contract. A host request can use a different route or bypass a Pod policy. Discovery, endpoint selection, connection establishment and application behavior remain separate stages even when they form one user-visible symptom.

<!-- astrona:playground:renew -->

For a timed catalog session, renew this module before continuing. Skip renewal for an untimed local author run:

```sh
astrona run renew astrona-io/ATS030/section-020/module-02/playground
```

Select the module environment and define a bounded retry helper:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-030-playground-020-02)"
test "$(kubectl config current-context)" = "kind-astro-ats-030-playground-020-02"
kubectl -n starfleet get pods
wait_for_success() {
  for attempt in 1 2 3 4 5 6 7 8 9 10; do
    if "$@"; then return 0; fi
    sleep 1
  done
  return 1
}
```

Observe a working request and change the selector with a complete JSON replacement.

```sh
wait_for_success kubectl -n starfleet exec shuttle -- wget -T 3 -qO- http://probe/
kubectl -n starfleet patch service probe --type=json -p '[{"op":"replace","path":"/spec/selector","value":{"app":"absent"}}]'
```

Replacement avoids accidentally retaining unrelated selector keys. Selectors are a logical conjunction of their conditions, so one missing label can empty the population.

Compare Service intent, actual Pod labels and ready endpoints, then verify that a new request cannot use the intended backend.

```sh
kubectl -n starfleet get service probe -o yaml
kubectl -n starfleet get pods --show-labels
kubectl -n starfleet get endpointslice -l kubernetes.io/service-name=probe -o yaml
CONNECTION_DENIED=0
for attempt in 1 2 3 4 5 6 7 8 9 10; do
  if kubectl -n starfleet exec shuttle -- wget -T 2 -qO- http://probe/ >/dev/null 2>&1; then sleep 1; else CONNECTION_DENIED=1; break; fi
done
test "$CONNECTION_DENIED" -eq 1
```

Give the endpoint controller time to update. An empty backend set is different from an application port refusal, so retain the relevant evidence.

Restore the full intended selector and observe the recovered path.

```sh
kubectl -n starfleet patch service probe --type=json -p '[{"op":"replace","path":"/spec/selector","value":{"app":"probe","release":"probe"}}]'
wait_for_success kubectl -n starfleet exec shuttle -- wget -T 3 -qO- http://probe/
```

The repair belongs to Service intent. Deleting healthy Pods would preserve the bad selector and repeat the same mismatch.

Use a fresh request together with API evidence. DNS can resolve a Service whose endpoints are unusable, and a healthy Pod can remain outside the selected population. The selected Service reference, namespace and labels should be explicit throughout diagnosis.

## Common pitfalls

> [!WARNING]
> Keep the selected module context and inspect the observed outcome. Resource acceptance does not establish readiness or a successful request. Reset this isolated environment if earlier experiments changed the required starting state.
