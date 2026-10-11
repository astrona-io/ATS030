---
draft: true
exam_objectives:
- Use Ingress rules to expose applications
---
# Ingress Routing And TLS Contracts

This module connects intended application behavior to declared resources and observed conditions.

## Learning Goals

- Identify IngressClass and controller responsibility.
- Compare exact, prefix and implementation-specific paths.
- Trace host and Service port matching.
- Explain TLS termination and backend protocol limits.

## Before You Start

Use the module playground for guided practice. It provides an isolated kind cluster and the declared starting fixtures. You need the Astrona command-line tool, kubectl and a working Podman engine; selected exercises also use Helm, curl or OpenSSL. Keep the module's private kubeconfig selected when running application commands.

## Reading Order

1. Matching Ingress Hosts, Paths And Service Backends
2. Route A Host And Path Through An Ingress Controller
3. Summary

The playground provides the initial state for the guided practice. Keep it open while following the practical steps.

<!-- astrona:playground -->
