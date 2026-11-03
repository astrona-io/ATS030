---
draft: true
exam_objectives:
- Demonstrate basic understanding of NetworkPolicies
---
# Isolate A Namespace In Both Directions

The platform team opened the `starfleet` namespace with a temporary policy during a migration. The migration is over. Close the namespace in both directions and open only the connections the application needs.

## Starting state

The Deployment `probe` (two pods, label `app: probe`, container port 8080) and the Service `probe` run in `starfleet`. The pod `shuttle` (label `app: shuttle`) runs in `starfleet`. The pod `drifter` runs in `outpost`. The NetworkPolicy `allow-everything` in `starfleet` allows all ingress. The cluster DNS runs in `kube-system`. Every namespace has the label `kubernetes.io/metadata.name`.

## Required result

1. Delete the NetworkPolicy `allow-everything`.
2. Create `default-deny-all` in `starfleet`. It selects every pod, isolates ingress and egress and has no rules.
3. Create `probe-ingress` in `starfleet`. The pods labelled `app: probe` accept TCP port 8080 only from the pod labelled `app: shuttle` in `starfleet`.
4. Create `shuttle-egress` in `starfleet`. The pod labelled `app: shuttle` may open connections only to the pods labelled `app: probe` on TCP 8080 and to the namespace `kube-system` on port 53 for both UDP and TCP.
5. Do not change the Deployment, the Service or the client pods.

The `shuttle` pod must receive `version=v1` from `http://probe/`. The `drifter` pod must time out when it requests `http://probe.starfleet/`. The `shuttle` pod must time out when it contacts the address of the `drifter` pod.

## Verify The Result

Wait a few seconds after you apply a policy. Check each client with `wget -q -T 3 -O-` through `kubectl exec`. Submit when all five requirements hold.
