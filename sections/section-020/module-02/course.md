---
draft: true
exam_objectives:
- Provide and troubleshoot access to applications via services
---
# Troubleshooting A Service Request

This module connects intended application behavior to declared resources and observed conditions.

## Learning Goals

- Trace a client request through discovery and Service routing.
- Distinguish selector, readiness and port failures.
- Evaluate policy and dependency effects on reachability.
- Choose a correction supported by the first failed relationship.

## Before You Start

Use the module playground for guided practice. It provides an isolated kind cluster and the declared starting fixtures. You need the Astrona command-line tool, kubectl and a working Podman engine; selected exercises also use Helm, curl or OpenSSL. Keep the module's private kubeconfig selected when running application commands.

## Reading Order

1. Tracing A Service Request
2. Trace A Missing Backend To Its Selector
3. Summary

The playground provides the initial state for the guided practice. Keep it open while following the practical steps.

<!-- astrona:playground -->
