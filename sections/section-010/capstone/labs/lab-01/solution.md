---
draft: true
exam_objectives:
- Demonstrate basic understanding of NetworkPolicies
---
# Isolate A Namespace In Both Directions Solution

Select the lab's private kubeconfig:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-030-capstone-010)"
test "$(kubectl config current-context)" = "kind-astro-ats-030-capstone-010" || exit 1
```

## Inspect the starting state

List the policies and the labels the selectors will use:

```sh
kubectl -n starfleet get networkpolicy
kubectl -n starfleet get pods --show-labels
kubectl get namespace kube-system --show-labels
```

The policy `allow-everything` has one empty ingress rule, which allows every source. Because policies only add allowed traffic, no later policy can close the namespace until this one is gone.

## Remove the open policy and close both directions

Delete the policy:

```sh
kubectl -n starfleet delete networkpolicy allow-everything
```

Save this as `networkpolicy-default-deny-all.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: starfleet
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

Apply it:

```sh
kubectl apply -f networkpolicy-default-deny-all.yaml
```

## Open the ingress of probe

Save this as `networkpolicy-probe-ingress.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: probe-ingress
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

Apply it:

```sh
kubectl apply -f networkpolicy-probe-ingress.yaml
```

## Open the egress of shuttle

A pod that is isolated for egress needs an egress rule for the application and one for DNS. Without the DNS rule, `probe` does not resolve. Save this as `networkpolicy-shuttle-egress.yaml`:

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
    - podSelector:
        matchLabels:
          app: probe
    ports:
    - protocol: TCP
      port: 8080
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
    ports:
    - protocol: UDP
      port: 53
    - protocol: TCP
      port: 53
```

Apply it:

```sh
kubectl apply -f networkpolicy-shuttle-egress.yaml
```

## Verify the result

Test the three paths. The first prints `version=v1`. The second and third fail with a timeout.

```sh
kubectl -n starfleet exec shuttle -- wget -q -T 3 -O- http://probe/
kubectl -n outpost exec drifter -- wget -q -T 3 -O- http://probe.starfleet/
kubectl -n starfleet exec shuttle -- wget -T 3 -O- "http://$(kubectl -n outpost get pod drifter -o jsonpath='{.status.podIP}'):8080/"
```

Submit with `astrona submit`, then remove the lab with `astrona destroy ats-030-capstone-010`.

## Common pitfalls

> [!WARNING]
> An egress default deny blocks DNS, so the name `probe` stops resolving until the DNS rule exists. A policy for ingress on `probe` does not open the egress of `shuttle`, because both ends must allow the connection. Forgetting to delete `allow-everything` leaves the namespace open.
