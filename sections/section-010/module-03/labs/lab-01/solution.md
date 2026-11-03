---
draft: true
exam_objectives:
- Demonstrate basic understanding of NetworkPolicies
---
# Default Deny With One Cross-Namespace Allow Solution

Select the lab's private kubeconfig:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-030-lab-010-03-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-030-lab-010-03-01" || exit 1
```

## Inspect the starting state

Check the labels that the selectors must match:

```sh
kubectl -n starfleet get pods --show-labels
kubectl -n outpost get pods --show-labels
kubectl get namespace outpost --show-labels
```

The `drifter` pod has the label `app: drifter`. The namespace `outpost` has the label `kubernetes.io/metadata.name=outpost`. A policy cannot deny, so the first step is a policy that isolates every pod and has no rules.

## Close the namespace

Save this as `networkpolicy-default-deny-ingress.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: starfleet
spec:
  podSelector: {}
  policyTypes:
  - Ingress
```

Apply it:

```sh
kubectl apply -f networkpolicy-default-deny-ingress.yaml
```

## Allow the one client

Save this as `networkpolicy-probe-from-drifter.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: probe-from-drifter
  namespace: starfleet
spec:
  podSelector:
    matchLabels:
      app: probe
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: outpost
      podSelector:
        matchLabels:
          app: drifter
    ports:
    - protocol: TCP
      port: 8080
```

Apply it:

```sh
kubectl apply -f networkpolicy-probe-from-drifter.yaml
```

The two selectors share one dash, so a pod must match both. The port is the container port 8080, because the policy applies after the Service translates port 80.

## Verify the result

Then check both clients. The first request prints `version=v1`. The second fails after three seconds with a timeout.

```sh
kubectl -n outpost exec drifter -- wget -q -T 3 -O- http://probe.starfleet/
kubectl -n starfleet exec shuttle -- wget -q -T 3 -O- http://probe/
```

Submit with `astrona submit`, then remove the lab with `astrona destroy ats-030-lab-010-03-01`.

## Common pitfalls

> [!WARNING]
> A second dash in the `from` list turns AND into OR and allows every pod of `outpost`. A policy that names port 80 matches nothing, because pods listen on 8080. A timeout means a policy block; a refusal means no process listens.
