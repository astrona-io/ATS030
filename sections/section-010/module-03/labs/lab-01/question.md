---
draft: true
exam_objectives:
- Demonstrate basic understanding of NetworkPolicies
---
# Default Deny With One Cross-Namespace Allow

The `probe` Service in `starfleet` currently answers every pod of the cluster. The `drifter` pod in `outpost` is the only client from another namespace that may keep using it. Close the namespace and allow that one client.

## Starting state

The Deployment `probe` (two pods, label `app: probe`, container port 8080) and the Service `probe` run in `starfleet`. The pod `shuttle` runs in `starfleet` and the pod `drifter` (label `app: drifter`) runs in `outpost`. No NetworkPolicy exists. Both namespaces carry the label `kubernetes.io/metadata.name`.

## Required result

1. Create the NetworkPolicy `default-deny-ingress` in `starfleet`. It selects every pod, isolates ingress and allows nothing.
2. Create the NetworkPolicy `probe-from-drifter` in `starfleet`. It selects the pods labelled `app: probe` and allows ingress on TCP port 8080 only from the pod labelled `app: drifter` in the namespace `outpost`. Use one `from` entry so that both conditions must match.
3. Do not change the Deployment, the Service or the client pods.

The `drifter` pod must receive a reply that contains `version=v1` through `http://probe.starfleet/`. The `shuttle` pod must time out when it requests `http://probe/`.

## Verify The Result

Use `kubectl -n outpost exec drifter -- wget -q -T 3 -O- http://probe.starfleet/` and the same form for `shuttle` in `starfleet`. Wait a few seconds after you apply a policy. Submit when both requests behave as described.
