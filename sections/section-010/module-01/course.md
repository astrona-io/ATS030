---
draft: true
exam_objectives:
- Demonstrate basic understanding of NetworkPolicies
---
# NetworkPolicy Selection And Allowed Connections

This module connects intended application behavior to declared resources and observed conditions.

## Learning Goals

- Explain policy selection and directional isolation.
- Evaluate additive ingress and egress allowances.
- Distinguish combined peer selectors from alternatives.
- Identify enforcement and permitted dependency requirements.

## Before You Start

Use the module playground for guided practice. It provides an isolated kind cluster and the declared starting fixtures. You need the Astrona command-line tool, kubectl and a working Podman engine; selected exercises also use Helm, curl or OpenSSL. Keep the module's private kubeconfig selected when running application commands.

## Reading Order

1. NetworkPolicy And Allowed Connections
2. Traffic Isolation And Allowed Peers
3. Enforce Ingress Isolation And One Allowed Peer
4. Summary

The playground provides the initial state for the guided practice. Keep it open while following the practical steps.

<!-- astrona:playground -->
