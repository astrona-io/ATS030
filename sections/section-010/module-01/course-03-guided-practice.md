---
draft: true
exam_objectives:
- Demonstrate basic understanding of NetworkPolicies
---
# Enforce Ingress Isolation And One Allowed Peer

This playground enables the Calico network-policy implementation. You will prove a working request before adding isolation, then permit the shuttle Pod and test a denied outpost client. A stored NetworkPolicy without a supporting implementation would not establish enforcement.

Use the module playground and its private kubeconfig. The context check below prevents commands from being directed at an unrelated cluster. The helper retries a command for a bounded interval after controller or policy changes; it cannot turn a persistent failure into success. Read the actual errors when the interval expires.

A policy is a declaration, while the network implementation enforces allowed connections. Calico supplies that capability in this environment. Compare an intended allowed caller with a deliberately disallowed caller rather than treating policy creation as the enforcement test.

Read peer selectors as structured conditions. Namespace and Pod selectors in one peer require both matches; separate peers form alternatives. The connection must also satisfy applicable source egress and destination ingress. Another applicable allowance can widen the union of permitted traffic.

<!-- astrona:playground:renew -->

For a timed catalog session, renew this module before continuing. Skip renewal for an untimed local author run:

```sh
astrona run renew astrona-io/ATS030/section-010/module-01/playground
```

Select the module environment and define a bounded retry helper:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-030-playground-010-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-030-playground-010-01"
kubectl -n starfleet get pods
wait_for_success() {
  for attempt in 1 2 3 4 5 6 7 8 9 10; do
    if "$@"; then return 0; fi
    sleep 1
  done
  return 1
}
```

Verify the baseline request, save the deny policy and apply it.

Save this as `networkpolicy-probe-deny.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: probe-deny
  namespace: starfleet
spec:
  podSelector:
    matchLabels:
      app: probe
  policyTypes:
  - Ingress
  ingress: []
```

Apply or use the saved input, then check the result:

```sh
wait_for_success kubectl -n starfleet exec shuttle -- wget -T 3 -qO- http://probe/
kubectl apply -f networkpolicy-probe-deny.yaml
CONNECTION_DENIED=0
for attempt in 1 2 3 4 5 6 7 8 9 10; do
  if kubectl -n starfleet exec shuttle -- wget -T 2 -qO- http://probe/ >/dev/null 2>&1; then sleep 1; else CONNECTION_DENIED=1; break; fi
done
test "$CONNECTION_DENIED" -eq 1
```

The bounded retry allows policy propagation. A failed request alone is not proof of policy correctness, so keep baseline, selected Pods and implementation evidence together.

Save a separate additive allow policy for the namespace-local shuttle peer and target container port.

Save this as `networkpolicy-probe-shuttle.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: probe-shuttle
  namespace: starfleet
spec:
  podSelector:
    matchLabels:
      app: probe
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: shuttle
    ports:
    - protocol: TCP
      port: 8080
```

Apply or use the saved input, then check the result:

```sh
kubectl apply -f networkpolicy-probe-shuttle.yaml
wait_for_success kubectl -n starfleet exec shuttle -- wget -T 3 -qO- http://probe/
kubectl -n starfleet get networkpolicy -o yaml
```

The allow rule adds permitted traffic; it does not cancel every other policy. The application listens on 8080 even though the Service receives port 80.

Try a fresh request from the outpost namespace and inspect the actual Pod labels.

```sh
CONNECTION_DENIED=0
for attempt in 1 2 3 4 5 6 7 8 9 10; do
  if kubectl -n outpost exec drifter -- wget -T 2 -qO- http://probe.starfleet/ >/dev/null 2>&1; then sleep 1; else CONNECTION_DENIED=1; break; fi
done
test "$CONNECTION_DENIED" -eq 1
kubectl -n starfleet get pods --show-labels
kubectl -n outpost get pods --show-labels
```

The local podSelector peer does not automatically include a same-labelled Pod in another namespace. The outpost request remains outside the selected allow population.

Validate both a permitted and a denied path. NetworkPolicy describes selected layer-three and layer-four connectivity, not HTTP authorization or encryption. If behavior differs, inspect selectors, direction, ports and implementation before assuming that object acceptance proves enforcement.

## Common pitfalls

> [!WARNING]
> Keep the selected module context and inspect the observed outcome. Resource acceptance does not establish readiness or a successful request. Reset this isolated environment if earlier experiments changed the required starting state.
