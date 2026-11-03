---
draft: true
exam_objectives:
- Provide and troubleshoot access to applications via services
---
# Service Types, Headless Services And Service DNS

A Service gives a changing set of pods one stable address. Which address, and who can use it, depends on the Service type. This module teaches the four types a developer must be able to create and explain: `ClusterIP`, `NodePort`, `LoadBalancer` and `ExternalName`. It also teaches headless Services and the DNS names that cluster DNS creates for every Service.

## Learning Goals

- Create a `ClusterIP`, `NodePort` and `LoadBalancer` Service and say which clients each one serves.
- Explain which component allocates the cluster IP, opens the node port and programs the forwarding.
- Create a headless Service and read the pod addresses it publishes in DNS.
- Create an `ExternalName` Service and explain why it never proxies traffic.
- Write the DNS name of a Service in its own namespace and from another namespace.

## Before You Start

The module playground is an isolated kind cluster. It runs the `probe` Deployment (two pods, label `app: probe`) and the Service `probe` in `starfleet`, the `shuttle` client pod in `starfleet` and the `drifter` client pod in `outpost`. You need the `astrona` command-line tool, `kubectl` and a working container engine.

## Reading Order

1. Service Types: ClusterIP, NodePort And LoadBalancer
2. Headless Services, ExternalName And Service DNS
3. Summary

The playground holds the starting state for both parts.

<!-- astrona:playground -->
