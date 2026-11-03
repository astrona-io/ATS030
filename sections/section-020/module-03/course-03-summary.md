---
draft: true
exam_objectives:
- Provide and troubleshoot access to applications via services
---
# Summary

A Service is a stable virtual address with a selector. The type decides who can use it. A `ClusterIP` Service answers inside the cluster. A `NodePort` Service adds a port from 30000 to 32767 on every node. A `LoadBalancer` Service adds a request for an external load balancer, and its `EXTERNAL-IP` stays `<pending>` where no component fulfils the request. In all three cases `kube-proxy` programs the forwarding on each node, and the EndpointSlice lists the ready pods.

Cluster DNS gives each Service the name `<service>.<namespace>.svc.cluster.local`. A client in another namespace needs at least `<service>.<namespace>`. A headless Service has `clusterIP: None`, creates no forwarding rules and answers with the pod addresses. An `ExternalName` Service answers with a CNAME to another name and never carries traffic.

- `kubectl expose` copies the selector of the workload. `kubectl create service` writes `app=NAME`.
- Named target ports keep a Service working when pods change their port numbers.
- `sessionAffinity: ClientIP` pins a client to one pod for a timeout.

<!-- astrona:playground:destroy -->
