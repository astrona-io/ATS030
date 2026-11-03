---
draft: true
exam_objectives:
- Provide and troubleshoot access to applications via services
---
# Headless Services, ExternalName And Service DNS

Clients rarely use a cluster IP directly. They use a name, and the cluster DNS (Domain Name System) service turns the name into an address. The cluster DNS is CoreDNS, which runs as pods in the `kube-system` namespace. This part shows the names CoreDNS creates, what changes when a Service has no cluster IP, and how a Service can point at a name instead of at pods.

## The DNS name of a Service

Every Service gets an A record (a record that maps a name to an IPv4 address) with the name `<service>.<namespace>.svc.<cluster-domain>`. The cluster domain is `cluster.local` by default. Inside the pod, the file `/etc/resolv.conf` lists search domains, so the short name `probe` works from a pod in `starfleet`, and `probe.starfleet` works from a pod in another namespace.

Select the private kubeconfig and resolve the Service from the `drifter` pod in `outpost`:

<!-- astrona:playground:renew -->

```sh
export KUBECONFIG="$(astrona kubeconfig ats-030-playground-020-03)"
kubectl -n outpost exec drifter -- nslookup probe.starfleet.svc.cluster.local
kubectl -n outpost exec drifter -- wget -q -T 3 -O- http://probe.starfleet/
```

The lookup returns the cluster IP of the `probe` Service, and the request returns `version=v1`. From `outpost` the short name `probe` does not work, because the search list of that pod holds `outpost.svc.cluster.local` and not `starfleet.svc.cluster.local`. Writing `probe.starfleet` is the shortest cross-namespace form.

## Headless Services

A headless Service has `clusterIP: None`. The API server allocates no virtual address, and `kube-proxy` programs no rules for it. CoreDNS answers a query for the Service name with the addresses of all ready pods, one A record per pod. The client receives the real pod addresses and picks one itself.

Headless Services suit clients that need every pod address, such as a database client that must find all members of a replicated database. StatefulSets use them to give each pod a stable DNS name.

Save this as `service-probe-headless.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: probe-headless
  namespace: starfleet
spec:
  clusterIP: None
  selector:
    app: probe
    release: probe
  ports:
  - name: http
    port: 8080
    targetPort: 8080
```

Apply it:

```sh
kubectl apply -f service-probe-headless.yaml
```

Then compare the answers for the normal Service and the headless Service, and list the pod addresses:

```sh
kubectl -n starfleet exec shuttle -- nslookup probe.starfleet.svc.cluster.local
kubectl -n starfleet exec shuttle -- nslookup probe-headless.starfleet.svc.cluster.local
kubectl -n starfleet get pods -l app=probe -o wide
```

The first lookup returns one address, the cluster IP. The second returns two addresses, which are the addresses of the two `probe` pods in the last command. If you delete one pod, the headless answer holds the address of its replacement after the pod is ready. Because no virtual address exists, a headless Service does no load balancing: the client decides.

The selector decides whether the Service has endpoints. A headless Service without a selector gets no EndpointSlice from the controller, and you can create the EndpointSlice yourself.

## ExternalName Services

An `ExternalName` Service has no selector, no cluster IP and no endpoints. It only stores a DNS name in `spec.externalName`. CoreDNS answers a query for the Service with a CNAME record (a record that says one name is an alias of another name), and the client then resolves the target name. No proxy touches the traffic, so the Service port is irrelevant.

Use it to give an external system, or a Service of another namespace, a local name. The `drifter` pod in `outpost` cannot use the short name `probe`. An `ExternalName` Service in `outpost` fixes that.

Save this as `service-probe-alias.yaml`:

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

Apply it:

```sh
kubectl apply -f service-probe-alias.yaml
```

Then resolve the alias and request it:

```sh
kubectl -n outpost exec drifter -- nslookup probe-alias.outpost.svc.cluster.local
kubectl -n outpost exec drifter -- wget -q -T 3 -O- http://probe-alias/
```

The lookup shows the canonical name `probe.starfleet.svc.cluster.local`, and the request returns `version=v1`. The same works for an external hostname. A web client that sends a `Host` header or uses TLS (Transport Layer Security) with the alias name can fail, because the name the client uses differs from the name the server expects. An `ExternalName` target must be a DNS name, not an IP address.

## Named ports and SRV records

A container port can have a name, and the Service `targetPort` can use that name instead of a number. The Service keeps working when the pods change their number, even if different pods of one Service use different numbers. For a named Service port, CoreDNS also creates an SRV record (a record that holds a port number and a host) named `_http._tcp.<service>.<namespace>.svc.cluster.local`.

## Command forms for the exam

The exam gives little time, so use the imperative forms. They create the same objects as YAML:

- `kubectl create service clusterip NAME --tcp=80:8080`
- `kubectl create service nodeport NAME --tcp=80:8080 --node-port=30080`
- `kubectl create service externalname NAME --external-name=example.com`
- `kubectl expose deployment NAME --port=80 --target-port=8080`

The `create service` commands set the selector `app=NAME`, so check it with `kubectl get service NAME -o yaml` and edit it if your pods use other labels. A headless Service from the command line needs `--cluster-ip=None` on `kubectl expose` or a YAML file.

## What you know now

Every Service has a DNS name, and the name form depends on the namespace of the client. A headless Service publishes pod addresses and leaves the choice to the client. An `ExternalName` Service is a DNS alias and never carries traffic. With types and names covered, the remaining work is to find which of these relationships is broken when a request fails.

## Common pitfalls

> [!WARNING]
> A headless Service does not balance load. An `ExternalName` Service cannot hold an IP address and does not proxy, so a port or TLS name mismatch comes from the client. `kubectl create service` writes the selector `app=NAME`, which is wrong for pods with other labels. The short name of a Service in another namespace does not resolve.
