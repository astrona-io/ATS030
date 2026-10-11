---
draft: true
exam_objectives:
- Provide and troubleshoot access to applications via services
---
# Services, Ports And Ready Backends

This module connects intended application behavior to declared resources and observed conditions.

## Learning Goals

- Explain Service selection and EndpointSlice relationships.
- Distinguish Service port, target port and application listener.
- Choose access behavior for supported Service types.
- Evaluate Pod addressing and backend readiness.

## Before You Start

Use the module playground for guided practice. It provides an isolated kind cluster and the declared starting fixtures. You need the Astrona command-line tool, kubectl and a working Podman engine; selected exercises also use Helm, curl or OpenSSL. Keep the module's private kubeconfig selected when running application commands.

## Reading Order

1. Selectors, Ports And Backends
2. Pod Addresses And Network Implementation
3. Repair A Service Target Port
4. Summary

The playground provides the initial state for the guided practice. Keep it open while following the practical steps.

<!-- astrona:playground -->
