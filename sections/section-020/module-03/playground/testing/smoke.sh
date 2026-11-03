#!/usr/bin/env bash
# UNTESTED author smoke script: replays the commands of the module readings.
set -euo pipefail
test "$(kubectl config current-context)" = "kind-astro-ats-030-playground-020-03"
kubectl -n starfleet get service probe
kubectl -n starfleet expose deployment probe --name=probe-nodeport --type=NodePort --port=80 --target-port=8080
kubectl -n starfleet get service probe-nodeport
kubectl -n starfleet expose deployment probe --name=probe-lb --type=LoadBalancer --port=80 --target-port=8080
kubectl -n starfleet get service probe-lb
kubectl -n starfleet create service externalname probe-alias --external-name=probe.starfleet.svc.cluster.local
kubectl -n starfleet expose deployment probe --name=probe-headless --cluster-ip=None --port=80 --target-port=8080
kubectl -n starfleet exec shuttle -- nslookup probe-headless.starfleet.svc.cluster.local
kubectl -n outpost exec drifter -- nslookup probe.starfleet.svc.cluster.local
kubectl -n outpost exec drifter -- wget -q -T 3 -O- http://probe.starfleet/
printf 'ATS030/020/03: practice checks passed\n'
