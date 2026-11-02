---
draft: true
exam_objectives:
- Use Ingress rules to expose applications
---
# Matching Ingress Hosts, Paths And Service Backends

A client requests `probe.local`, and Traefik chooses an Ingress route before forwarding to the `probe` Service. The Ingress object declares matching rules; the controller implements them. A rule stored without an active controller cannot provide the same routing behavior.

## Learning objectives

- Trace host and path matching into a Service backend.
- Distinguish IngressClass selection from resource acceptance.
- Explain frontend TLS termination and its backend limits.

## Before you start

Use a shell on your own machine with the module playground running. A Pod is Kubernetes's unit for running one or more containers together. The environment provides the `probe` Deployment, which maintains application Pods, and the `starfleet` namespace, which groups these objects.

Read-only commands below use kubectl, the Kubernetes command-line tool. Select the private kubeconfig: the file that identifies this environment's cluster and credentials. The commands do not change the application.

## Matching Ingress Hosts, Paths and Service Backends

An Ingress declares rules for routing external HTTP or HTTPS traffic to Services. HTTP means Hypertext Transfer Protocol; HTTPS is HTTP protected through Transport Layer Security (TLS). An Ingress controller interprets the resource and configures the actual traffic-handling infrastructure. Creating the resource without a suitable controller does not create a working external entry point.

## Identify The Controller Contract

An IngressClass identifies how an Ingress should be handled under the relevant configuration. The Ingress can select a class explicitly, while cluster defaults and controller behavior determine what happens when it does not. A controller listening for another class may ignore an otherwise valid resource.

Controller-specific annotations can affect behavior, but they are not universal Ingress semantics. A path rewrite supported by one controller cannot be assumed to work on every implementation. Begin with the standard host, path and backend model before relying on implementation extensions.

The controller itself also needs a reachable entry point, such as a provisioned load balancer or another appropriate network arrangement. An address in an Ingress status field is useful evidence, but it does not by itself prove that Domain Name System (DNS), client routing and application configuration all align.

## Follow Host And Path Selection

A host rule matches the request's host according to Ingress semantics. Sending a request to the controller address with an unrelated host can miss the intended rule. DNS maps the application's hostname to an entry address, while host routing selects which declared rule should handle the request. These are separate operations.

An `Exact` path type matches the declared path exactly. A `Prefix` path type matches using path elements rather than arbitrary text-prefix matching. For example, a prefix `/reports` can cover `/reports/daily` without necessarily matching `/reports-old` as the same path element. `ImplementationSpecific` delegates interpretation to the selected implementation.

Where several paths match, the supported precedence rules select the appropriate route, including preference for a longer match and exact matching at otherwise equivalent paths. A default backend can handle requests that do not match declared rules when configured. A default response from the controller is therefore different from an error emitted by the intended application backend.

## Resolve The Backend Port Relationship

A standard backend identifies a Service in the Ingress's namespace and a Service port by number or name. That reference is to the Service port, not directly to an arbitrary container port. The Service's own `targetPort` then maps the request toward its selected Pod endpoints.

Suppose the Service exposes port 80 and forwards to container port 8080. The Ingress backend references Service port 80, while the application must listen at the backend target. Pointing the Ingress to 8080 merely because the container uses that port can be incorrect if the Service exposes no such port.

The Service selector and endpoint readiness remain essential. A route can match the right host and path but still have no eligible backend. Ingress matching, Service selection, target-port mapping and application listening form a chain of independent relationships.

## TLS And Application Assumptions

A TLS configuration can reference a Secret containing certificate and key material in the expected namespace. The requested hostname should be covered by the certificate. A certificate for another name can fail client verification even when HTTP routing rules are otherwise correct.

TLS termination at the controller does not automatically mean the controller-to-backend connection is encrypted. That depends on the controller and backend configuration. Likewise, standard path matching does not universally rewrite the path passed to the application. A backend expecting `/` can return an error when it receives `/reports` unless the application or supported routing configuration handles that path.

The useful design exercise is to trace one request from hostname resolution through class selection, host and path matching, Service port selection and the ready backend. At each point, identify the declared rule and the responsible component. That sequence supports both a correct definition and a focused diagnosis.

## Inspect the mechanism

An Ingress declares supported external web routing, including host, path and backend Service port. Its IngressClass identifies the controller contract. This playground installs Traefik, which observes matching resources and serves the frontend connection. Inspect the class and controller before assuming that an accepted route is realized.

Transport Layer Security (TLS) can terminate at that frontend, using a certificate for the requested hostname. Certificate trust and hostname match are different checks from route matching. TLS on the frontend does not automatically encrypt the controller-to-Service hop. The basic practice backend uses plain Hypertext Transfer Protocol (HTTP), so describe this boundary explicitly rather than claiming end-to-end encryption.

```mermaid
flowchart TB
    C["Client hostname and path"] --> T["Traefik frontend"]
    I["Ingress and class"] --> T
    T --> S["Selected Service port"]
    S --> E["Ready backend"]
    E --> A["Application response"]
```

The controller converts declared matching rules into a frontend-to-backend request path.

<!-- astrona:playground:renew -->

Select the private cluster connection and inspect the live state from your host shell:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-030-playground-030-01)"
if test "$(kubectl config current-context)" = "kind-astro-ats-030-playground-030-01"; then
  kubectl get ingressclasses
  kubectl -n starfleet get ingresses -o yaml
  kubectl -n starfleet get services
  kubectl -n starfleet get deployments
else
  printf "Select this module's private kubeconfig before continuing.\n" >&2
fi
```

Locate the provisioned controller and class, then inspect any existing Ingress rules. The baseline may have no route before you create one in practice. An empty route list does not mean Traefik is missing. These API queries establish configuration evidence; they do not negotiate TLS or test the public hostname and path.

You can now separate route declaration, controller realization and connection security. A working external request still needs matching host and path, reachable backends and the intended certificate trust contract.

## Common pitfalls

> [!WARNING]
> An Ingress needs a matching controller and a reachable entry point. Match the Service's exposed port, distinguish prefix path elements from arbitrary string prefixes, and do not assume that path rewriting or backend encryption happens automatically.
