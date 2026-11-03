---
draft: true
exam_objectives:
- Provide and troubleshoot access to applications via services
---
# Create Three Service Types For One Application

The Deployment `probe` in `starfleet` has two pods. Only the ClusterIP Service `probe` exists. Add three more Services that reach the same pods in three different ways.

## Starting state

The Deployment `probe` (two pods, labels `app: probe` and `release: probe`, container port 8080 named `http`) and the Service `probe` (port 80) run in `starfleet`. The pod `shuttle` runs in `starfleet` and the pod `drifter` runs in `outpost`. No other Service exists.

## Required result

1. Create the Service `probe-node` in `starfleet`. It has type `NodePort`, selects `app: probe`, exposes port 80, targets the named port `http` and uses the node port 30081.
2. Create the headless Service `probe-pods` in `starfleet`. It selects `app: probe` and has no cluster IP.
3. Create the Service `probe-alias` in `outpost`. It has type `ExternalName` and points to `probe.starfleet.svc.cluster.local`.
4. Do not change the Deployment, the Service `probe` or the client pods.

The `drifter` pod must receive `version=v1` from `http://probe-alias/`. The name `probe-pods.starfleet.svc.cluster.local` must resolve to the address of each probe pod.

## Verify The Result

Use `kubectl -n outpost exec drifter -- wget -q -T 3 -O- http://probe-alias/` and `kubectl -n starfleet exec shuttle -- nslookup probe-pods.starfleet.svc.cluster.local`. Submit when both behave as described.
