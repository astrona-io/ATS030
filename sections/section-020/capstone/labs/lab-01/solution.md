---
draft: true
exam_objectives:
- Provide and troubleshoot access to applications via services
---
# Repair And Expose An Application With Services Solution

Select the lab's private kubeconfig:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-030-capstone-020)"
test "$(kubectl config current-context)" = "kind-astro-ats-030-capstone-020" || exit 1
```

## Find why the Service has no endpoints

Compare the selector of the Service with the labels of the pods, and the target port with the container port.

```sh
kubectl -n starfleet get service probe -o yaml
kubectl -n starfleet get pods --show-labels
kubectl -n starfleet get endpointslices -l kubernetes.io/service-name=probe
```

The Service selects `release: probe-v2`, but the pods carry `release: probe`, so the EndpointSlice has no endpoints. The `targetPort` is 9090, but the container listens on 8080 under the name `http`. Two faults hide each other: fixing only one still gives no working Service.

## Repair the Service

Save this as `service-probe.yaml` and apply it:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: probe
  namespace: starfleet
spec:
  selector:
    app: probe
    release: probe
  ports:
  - name: http
    port: 80
    targetPort: http
```

```sh
kubectl apply -f service-probe.yaml
kubectl -n starfleet get endpointslices -l kubernetes.io/service-name=probe
kubectl -n starfleet exec shuttle -- wget -q -T 3 -O- http://probe/
```

## Add the NodePort and headless Services

Save these as `service-probe-node.yaml` and `service-probe-pods.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: probe-node
  namespace: starfleet
spec:
  type: NodePort
  selector:
    app: probe
  ports:
  - name: http
    port: 80
    targetPort: http
    nodePort: 30090
---
apiVersion: v1
kind: Service
metadata:
  name: probe-pods
  namespace: starfleet
spec:
  clusterIP: None
  selector:
    app: probe
  ports:
  - name: http
    port: 80
    targetPort: http
```

```sh
kubectl apply -f service-probe-node.yaml -f service-probe-pods.yaml
kubectl -n starfleet exec shuttle -- nslookup probe-pods.starfleet.svc.cluster.local
```

## Add the ExternalName Service in outpost

The Service has the name `probe` in `outpost`, so the short name `probe` works there. An `ExternalName` Service has no selector.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: probe
  namespace: outpost
spec:
  type: ExternalName
  externalName: probe.starfleet.svc.cluster.local
```

```sh
kubectl apply -f service-probe-external.yaml
kubectl -n outpost exec drifter -- wget -q -T 3 -O- http://probe/
```

## Verify the result

Submit with `astrona submit`, then remove the lab with `astrona destroy ats-030-capstone-020`.

## Common pitfalls

> [!WARNING]
> Check the EndpointSlice before you change anything. A wrong selector and a wrong `targetPort` both end in a Service that does not answer. An `ExternalName` Service in the namespace of the client needs the full DNS name of the target.
