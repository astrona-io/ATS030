---
draft: true
exam_objectives:
- Use Ingress rules to expose applications
---
# External Request Diagnosis

This module connects intended application behavior to declared resources and observed conditions.

## Learning Goals

- Distinguish lookup, transport, routing and application errors.
- Identify whether the controller or backend produced a response.
- Evaluate endpoint readiness, ports and applicable traffic policy.
- Verify the intended host, path and secure application response.

## Before You Start

Use the module playground for guided practice. It provides an isolated kind cluster and the declared starting fixtures. You need the Astrona command-line tool, kubectl and a working Podman engine; selected exercises also use Helm, curl or OpenSSL. Keep the module's private kubeconfig selected when running application commands.

## Reading Order

1. Tracing An External Request To The Application
2. Locate A Broken Ingress Backend Reference
3. Summary

The playground provides the initial state for the guided practice. Keep it open while following the practical steps.

<!-- astrona:playground -->
