---
draft: true
exam_objectives:
- Provide and troubleshoot access to applications via services
---
# Repair And Expose An Application With Services

A team moved the `probe` application to new pods. Its Service stopped answering. Repair it, then publish the application three more ways.

## Starting state

The Deployment `probe` (two pods, labels `app: probe` and `release: probe`, container port 8080 named `http`) runs in `starfleet`. The Service `probe` in `starfleet` has no ready endpoints. The pod `shuttle` runs in `starfleet` and the pod `drifter` runs in `outpost`. No other Service exists.

## Required result

1. Repair the Service `probe` in `starfleet`. It keeps port 80, selects the pods of the Deployment and targets the container port by the name `http`.
2. Create the Service `probe-node` in `starfleet`. It has type `NodePort`, selects `app: probe`, exposes port 80, targets `http` and uses node port 30090.
3. Create the headless Service `probe-pods` in `starfleet`. It selects `app: probe`.
4. Create the Service `probe` in `outpost`. It has type `ExternalName` and points to `probe.starfleet.svc.cluster.local`.
5. Do not change the Deployment or the client pods.

Both `shuttle` and `drifter` must receive `version=v1` from `http://probe/`. The name `probe-pods.starfleet.svc.cluster.local` must resolve to the address of each probe pod.

## Verify The Result

Check the EndpointSlices of `probe` first. Then run `wget -q -T 3 -O- http://probe/` in both client pods and `nslookup probe-pods.starfleet.svc.cluster.local` in `shuttle`. Submit when all of them behave as described.
