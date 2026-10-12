---
draft: true
exam_objectives:
- Demonstrate basic understanding of NetworkPolicies
---
# Dependency-Aware Network Isolation

Egress isolation allows the destination Pod but blocks the resolver. The application cannot look up `probe`, so it never reaches the permitted backend connection. Dependencies include name resolution as well as the final Service.

## Learning Goals

- Explain DNS lookup and Service discovery dependencies.
- Distinguish name resolution from backend connectivity.
- Identify required traffic under restrictive egress.
- Diagnose address, listener and policy failures separately.

## Before You Start

Use the module playground for guided practice. It provides an isolated kind cluster and the declared starting fixtures. You need the Astrona command-line tool, kubectl and a working Podman engine; selected exercises also use Helm, curl or OpenSSL. Keep the module's private kubeconfig selected when running application commands.

## Reading Order

1. DNS And Service Discovery
2. Allow DNS And The Application As Separate Dependencies
3. Summary

The playground provides the initial state for the guided practice. Keep it open while following the practical steps.

<!-- astrona:playground -->
