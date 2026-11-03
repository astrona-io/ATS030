---
draft: true
exam_objectives:
- Provide and troubleshoot access to applications via services
---
# Create Three Service Types For One Application Solution

Select the lab's private kubeconfig:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-030-lab-020-03-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-030-lab-020-03-01" || exit 1
```

## Inspect the starting state

Check the labels of the pods and the container port name. The Services you create select the pods by label and reach the container by port name.

```sh
kubectl -n starfleet get pods --show-labels
kubectl -n starfleet get service probe -o yaml
kubectl -n starfleet get deployment probe -o jsonpath='{.spec.template.spec.containers[0].ports}'
```

The pods carry `app=probe` and the container port is named `http`.

## Create the NodePort Service

Save this as `service-probe-node.yaml`:

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
    nodePort: 30081
```

```sh
kubectl apply -f service-probe-node.yaml
kubectl -n starfleet get service probe-node
```

The `PORT(S)` column shows `80:30081/TCP`.

## Create the headless Service

Save this as `service-probe-pods.yaml`. Setting `clusterIP: None` makes the Service headless: it gets no cluster IP, and DNS answers with the pod addresses.

```yaml
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
kubectl apply -f service-probe-pods.yaml
kubectl -n starfleet exec shuttle -- nslookup probe-pods.starfleet.svc.cluster.local
```

The lookup prints two addresses, one for each pod.

## Create the ExternalName Service

Save this as `service-probe-alias.yaml`. It goes in `outpost`, so the short name `probe-alias` works there. An `ExternalName` Service has no selector and no ports. Cluster DNS answers with a CNAME record for the target name.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: probe-alias
  namespace: outpost
spec:
  type: ExternalName
  externalName: probe.starfleet.svc.cluster.local
```

```sh
kubectl apply -f service-probe-alias.yaml
kubectl -n outpost exec drifter -- wget -q -T 3 -O- http://probe-alias/
```

The request prints `version=v1`. The client connects to the Service `probe` on port 80, because the alias only renames the destination.

## Verify the result

Submit with `astrona submit`, then remove the lab with `astrona destroy ats-030-lab-020-03-01`.

## Common pitfalls

> [!WARNING]
> A node port outside 30000-32767 is rejected. A headless Service with a wrong selector has no addresses, so the lookup returns nothing. An `ExternalName` Service never proxies: the port you request must exist on the target name.
