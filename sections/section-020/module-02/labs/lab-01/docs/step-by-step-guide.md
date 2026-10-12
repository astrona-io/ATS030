---
draft: true
exam_objectives:
- Provide and troubleshoot access to applications via services
---
# Diagnose And Repair The Backend Mapping

## Objective

Restore the original client request by repairing only the Service's backend port mapping.

## Prerequisites

Use a host shell with kubectl and this lab's private kubeconfig. The launch action starts the separate lab environment; these commands do not reuse the module playground.

## Starting state

The Deployment has two healthy replicas and listens on port 8080. The Service exposes port 80 but targets 9090. DNS and direct application access work; the Service request does not.

Select and confirm the lab connection before inspecting objects. The condition prevents the commands inside it from running against another context:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-030-lab-020-02-01)"
if test "$(kubectl config current-context)" = "kind-astro-ats-030-lab-020-02-01"; then
  kubectl -n starfleet get service probe -o yaml
  kubectl -n starfleet get pods -l app=probe --show-labels
  kubectl -n starfleet get endpointslices -l kubernetes.io/service-name=probe -o yaml
else
  printf "Select the lab's private kubeconfig before continuing.\n" >&2
fi
```

Match the Service selector with both Pod labels. Then compare Service port 80, target port 9090 and the application's declared port named `http`, which maps to 8080. Endpoint readiness establishes backend eligibility, while the wrong target port establishes a separate forwarding defect.

Save this as `service-probe.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: probe
  namespace: starfleet
spec:
  type: ClusterIP
  selector:
    app: probe
    release: probe
  ports:
  - name: http
    port: 80
    targetPort: http
    protocol: TCP
```

Apply it after confirming the same lab context. This changes forwarding for new Service connections in the isolated lab. It preserves the client-facing port and uses the application's existing named listener:

```sh
if test "$(kubectl config current-context)" = "kind-astro-ats-030-lab-020-02-01"; then
  kubectl apply -f service-probe.yaml
else
  printf "Select the lab's private kubeconfig before continuing.\n" >&2
fi
```

## Verify the result

Check controller convergence and repeat the original request from shuttle. Network-rule updates may take a short time after object acceptance; retry the bounded request if propagation is still in progress.

```sh
if test "$(kubectl config current-context)" = "kind-astro-ats-030-lab-020-02-01"; then
  kubectl -n starfleet rollout status deployment/probe --timeout=120s
  kubectl -n starfleet get endpointslices -l kubernetes.io/service-name=probe -o yaml
  kubectl -n starfleet exec shuttle -- wget -q -T 3 -O- http://probe/
else
  printf "Select the lab's private kubeconfig before continuing.\n" >&2
fi
```

Read the actual response. It identifies version one and a probe Pod; the generated Pod name varies. No transcript is supplied as a claim of a completed run. A successful request through the original Service provides stronger evidence than checking its corrected field alone.

The mapping fault is now explained by the distinction between client port and backend target port. The application, selector and capacity did not need replacement.

After recording your result, end this independent lab environment with `astrona destroy ats-030-lab-020-02-01`. This removes its practice resources; it does not end the separate module playground.

## Common pitfalls

> [!WARNING]
> Changing the client-facing port moves the access contract rather than fixing its backend. Direct Pod access does not verify Service forwarding, and a declared container port does not itself create a listener.
