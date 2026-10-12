---
draft: true
exam_objectives:
- Provide and troubleshoot access to applications via services
---
# Repair A Service Target Port

A Service selects ready endpoints and maps its incoming port to a target port. You will deliberately select a nonexistent application port while leaving the Pods healthy. This distinguishes a Service forwarding failure from an unhealthy application process.

Use the module playground and its private kubeconfig. The context check below prevents commands from being directed at an unrelated cluster. The helper retries a command for a bounded interval after controller or policy changes; it cannot turn a persistent failure into success. Read the actual errors when the interval expires.

The Service uses labels to select Pods and a named target port to select the backend listener port. Match each relationship explicitly. The application process must still bind that port; a containerPort field does not start a socket.

EndpointSlice readiness and actual Pod addresses expose the selected backend population. These addresses can change during replacement while the Service access point remains stable. Inspect the population and mapping before treating an accepted Service as proof of usable traffic.

<!-- astrona:playground:renew -->

For a timed catalog session, renew this module before continuing. Skip renewal for an untimed local author run:

```sh
astrona run renew astrona-io/ATS030/section-020/module-01/playground
```

Select the module environment and define a bounded retry helper:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-030-playground-020-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-030-playground-020-01"
kubectl -n starfleet get pods
wait_for_success() {
  for attempt in 1 2 3 4 5 6 7 8 9 10; do
    if "$@"; then return 0; fi
    sleep 1
  done
  return 1
}
```

Verify the baseline response and inspect the application port declaration. Save a Service that changes only the target port.

Save this as `service-probe-wrong-port.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: probe
  namespace: starfleet
spec:
  selector:
    app: probe
    release: probe
  ports:
  - name: http
    port: 80
    targetPort: 8099
```

Apply or use the saved input, then check the result:

```sh
wait_for_success kubectl -n starfleet exec shuttle -- wget -T 3 -qO- http://probe/
kubectl apply -f service-probe-wrong-port.yaml
```

The Service still selects the same Pods, so healthy Pod status does not prove that requests reach a listening target.

Inspect Service and EndpointSlice ports, then observe a failed fresh request.

```sh
kubectl -n starfleet get service probe -o yaml
kubectl -n starfleet get endpointslice -l kubernetes.io/service-name=probe -o yaml
CONNECTION_DENIED=0
for attempt in 1 2 3 4 5 6 7 8 9 10; do
  if kubectl -n starfleet exec shuttle -- wget -T 2 -qO- http://probe/ >/dev/null 2>&1; then sleep 1; else CONNECTION_DENIED=1; break; fi
done
test "$CONNECTION_DENIED" -eq 1
```

A ready address with the wrong port is not the same condition as no ready addresses. Compare the target port with the actual named container port.

Save and apply the corrected complete Service, then repeat the request.

Save this as `service-probe-correct.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: probe
  namespace: starfleet
spec:
  selector:
    app: probe
    release: probe
  ports:
  - name: http
    port: 80
    targetPort: http
```

Apply or use the saved input, then check the result:

```sh
kubectl apply -f service-probe-correct.yaml
wait_for_success kubectl -n starfleet exec shuttle -- wget -T 3 -qO- http://probe/
```

The response checks the repaired forwarding path. It does not prove every application endpoint or external request path is healthy.

Follow selector, readiness, endpoint port and process listener as separate contracts. Pod health alone is insufficient when a Service points elsewhere. A named target port is resolved from selected Pod declarations, while a numeric target is used as the selected number.

## Common pitfalls

> [!WARNING]
> Keep the selected module context and inspect the observed outcome. Resource acceptance does not establish readiness or a successful request. Reset this isolated environment if earlier experiments changed the required starting state.
