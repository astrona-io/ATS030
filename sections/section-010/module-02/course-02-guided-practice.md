---
draft: true
exam_objectives:
- Demonstrate basic understanding of NetworkPolicies
---
# Allow DNS And The Application As Separate Dependencies

An egress-isolated client needs access to name resolution and to the application path. You will observe a working Service-name request, apply an empty egress allowance and then add narrowly selected DNS and application rules. Calico supplies enforcement in this module environment.

Use the module playground and its private kubeconfig. The context check below prevents commands from being directed at an unrelated cluster. The helper retries a command for a bounded interval after controller or policy changes; it cannot turn a persistent failure into success. Read the actual errors when the interval expires.

The caller needs to reach its resolver before a backend name is useful. Egress isolation can therefore break discovery even when the final backend is allowed. Read the actual resolver configuration and provisioned DNS components instead of assuming a label or address from another cluster.

The namespace-qualified Service name distinguishes the intended backend from a same-named Service in another namespace. A successful lookup still leaves backend selection, policy and listener reachability unresolved. Keep DNS recovery and application connection recovery as separate observations.

<!-- astrona:playground:renew -->

For a timed catalog session, renew this module before continuing. Skip renewal for an untimed local author run:

```sh
astrona run renew astrona-io/ATS030/section-010/module-02/playground
```

Select the module environment and define a bounded retry helper:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-030-playground-010-02)"
test "$(kubectl config current-context)" = "kind-astro-ats-030-playground-010-02"
kubectl -n starfleet get pods
wait_for_success() {
  for attempt in 1 2 3 4 5 6 7 8 9 10; do
    if "$@"; then return 0; fi
    sleep 1
  done
  return 1
}
```

Check name resolution and the baseline request, then isolate the shuttle Pod.

Save this as `networkpolicy-shuttle-deny.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: shuttle-egress
  namespace: starfleet
spec:
  podSelector:
    matchLabels:
      app: shuttle
  policyTypes:
  - Egress
  egress: []
```

Apply or use the saved input, then check the result:

```sh
kubectl -n starfleet exec shuttle -- nslookup probe.starfleet.svc.cluster.local
wait_for_success kubectl -n starfleet exec shuttle -- wget -T 3 -qO- http://probe/
kubectl apply -f networkpolicy-shuttle-deny.yaml
CONNECTION_DENIED=0
for attempt in 1 2 3 4 5 6 7 8 9 10; do
  if kubectl -n starfleet exec shuttle -- wget -T 2 -qO- http://probe/ >/dev/null 2>&1; then sleep 1; else CONNECTION_DENIED=1; break; fi
done
test "$CONNECTION_DENIED" -eq 1
```

The failed Service-name request can include a DNS failure as well as an application connection failure. Diagnose those dependencies separately.

Save the complete allowed egress population. The DNS peer combines namespace and Pod selectors in one item, so both conditions must hold.

Save this as `networkpolicy-shuttle-allow.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: shuttle-egress
  namespace: starfleet
spec:
  podSelector:
    matchLabels:
      app: shuttle
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
      podSelector:
        matchLabels:
          k8s-app: kube-dns
    ports:
    - protocol: UDP
      port: 53
    - protocol: TCP
      port: 53
  - to:
    - podSelector:
        matchLabels:
          app: probe
    ports:
    - protocol: TCP
      port: 8080
```

Apply or use the saved input, then check the result:

```sh
kubectl apply -f networkpolicy-shuttle-allow.yaml
kubectl -n starfleet get networkpolicy shuttle-egress -o yaml
```

The second rule permits the target Pods on container port 8080. It does not open every destination merely because one application uses a Service.

Repeat resolution and an application request after policy propagation.

```sh
kubectl -n starfleet exec shuttle -- nslookup probe.starfleet.svc.cluster.local
wait_for_success kubectl -n starfleet exec shuttle -- wget -T 3 -qO- http://probe/
kubectl -n kube-system get pods -l k8s-app=kube-dns --show-labels
```

The selected cluster DNS labels are an explicit environment dependency. A production cluster with a different DNS architecture requires a corresponding reviewed rule.

Name resolution success is not application authorization, and an application allow does not automatically permit DNS. State the selected directions and target ports. This exercise uses concrete selectors instead of an unrestricted egress rule that hides dependency reasoning.

## Common pitfalls

> [!WARNING]
> Keep the selected module context and inspect the observed outcome. Resource acceptance does not establish readiness or a successful request. Reset this isolated environment if earlier experiments changed the required starting state.
