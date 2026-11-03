---
draft: true
exam_objectives:
- Demonstrate basic understanding of NetworkPolicies
---
# Peer Selectors, IP Blocks And Ports

A default deny policy closes a namespace, and the policies that follow must open it for exactly the right peers. A peer is the other end of a connection. NetworkPolicy offers three ways to name a peer: by pod labels, by namespace labels and by IP address range. A small difference in YAML layout changes which of these combine, and that difference is the most common source of policies that allow too much.

## The three peer types

Each entry of a `from` list (for ingress) or a `to` list (for egress) is one peer, and it holds one or more of these fields:

- `podSelector` matches pods by label in the policy's own namespace, unless a `namespaceSelector` is in the same entry.
- `namespaceSelector` matches all pods in every namespace whose labels match.
- `ipBlock` matches an address range written as a CIDR (Classless Inter-Domain Routing) block, such as `10.0.0.0/16`, with an optional `except` list.

Every namespace carries the label `kubernetes.io/metadata.name` with its own name as value. The label lets a policy select a namespace without any label work from an administrator.

<!-- astrona:playground:renew -->

```sh
export KUBECONFIG="$(astrona kubeconfig ats-030-playground-010-03)"
kubectl get namespace starfleet outpost --show-labels
```

The output lists `kubernetes.io/metadata.name=starfleet` and `kubernetes.io/metadata.name=outpost` among the labels of the two namespaces. The playground starts with no policy, so the commands in this part first close the `starfleet` namespace again.

Save this as `default-deny-ingress.yaml`:

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
kubectl apply -f default-deny-ingress.yaml
```

## The AND form and the OR form

Two pieces of YAML that look almost the same behave differently. In the first, the `namespaceSelector` and the `podSelector` sit in one list entry. The entry matches a pod only when both selectors match: the pod must have the label `app: drifter` and live in a namespace named `outpost`. This is a logical AND.

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

Apply it and test the `drifter` pod and the `shuttle` pod:

```sh
kubectl apply -f networkpolicy-probe-from-drifter.yaml
kubectl -n outpost exec drifter -- wget -q -T 3 -O- http://probe.starfleet/
kubectl -n starfleet exec shuttle -- wget -q -T 3 -O- http://probe/
```

The first request succeeds. The second times out, because `shuttle` lives in `starfleet`, not in `outpost`, and the default deny policy closes the rest.

In the second layout the two selectors start two separate list entries, each with its own dash. The entries are alternatives, a logical OR. The policy then allows every pod of every namespace named `outpost`, and also every pod labelled `app: drifter` in the policy's own namespace.

```yaml
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: outpost
    - podSelector:
        matchLabels:
          app: drifter
```

The only difference is one dash, and the second layout allows far more. When you review a policy, count the dashes under `from` and `to` before you read the labels. One dash with two selectors means AND. Two dashes mean OR.

## Rules with several entries and ports

A rule has two optional lists: `from` or `to` for peers, and `ports`. A connection matches the rule when it matches at least one peer and at least one port. If `from` is missing, the rule allows every source on the listed ports. If `ports` is missing, it allows every port from the listed peers. An entirely empty rule allows everything.

A port entry has a `protocol` (`TCP` by default, `UDP` or `SCTP`) and a `port`. The port may be a number or the name of a container port. The field `endPort` turns a number into an inclusive range: `port: 32000` with `endPort: 32768` allows the ports 32000 to 32768. The `endPort` field needs a numeric `port` and a value that is not lower than `port`.

## IP blocks

An `ipBlock` allows a CIDR range. Its `except` list removes sub-ranges, and each exception must lie inside the `cidr`. IP blocks suit addresses outside the cluster, such as a database server or an office network, because pod addresses change when pods restart. Pod-to-pod traffic keeps its source address, so an `ipBlock` can match a pod, but labels are the stable way to name one.

Read the address of the `drifter` pod:

```sh
kubectl -n outpost get pod drifter -o jsonpath='{.status.podIP}'
```

Save this as `networkpolicy-probe-from-block.yaml`. Replace `<DRIFTER_IP>` with the address from the command above:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: probe-from-block
  namespace: starfleet
spec:
  podSelector:
    matchLabels:
      app: probe
  policyTypes:
  - Ingress
  ingress:
  - from:
    - ipBlock:
        cidr: <DRIFTER_IP>/32
    ports:
    - protocol: TCP
      port: 8080
```

Remove the label-based policy and apply the block policy:

```sh
kubectl -n starfleet delete networkpolicy probe-from-drifter
kubectl apply -f networkpolicy-probe-from-block.yaml
kubectl -n outpost exec drifter -- wget -q -T 3 -O- http://probe.starfleet/
```

The request succeeds because the source address of the `drifter` pod is inside the `/32` block. A `/32` block holds exactly one address. If you restart the `drifter` pod, it receives a new address and the policy stops matching. That is why the label forms are preferred for pods.

## What you know now

Peers are named by pod labels, namespace labels or address blocks. One list entry with two selectors means AND, and two entries mean OR. Ports narrow a rule by protocol, number and range. The next question is what happens to pods that must also leave the namespace, which is the topic of egress policies.

## Common pitfalls

> [!WARNING]
> A missing dash turns an AND into an OR and opens a namespace to every pod. A `podSelector` alone never reaches another namespace. An `ipBlock` for a pod breaks when the pod gets a new address. `endPort` does not work with a named port.
