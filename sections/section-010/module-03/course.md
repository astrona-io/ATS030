---
draft: true
exam_objectives:
- Demonstrate basic understanding of NetworkPolicies
---
# Default Deny, Peer Selectors And IP Blocks

The `probe` Service in `starfleet` answers every client that can reach it. A NetworkPolicy changes that: it lists which connections a pod accepts or makes, and the network plugin drops the rest. This module teaches the three tools that make a policy exact: a default deny policy that closes a namespace, peer selectors that name who may connect, and IP blocks and ports that narrow the allowance further.

## Learning Goals

- Explain how a pod becomes isolated and why policies only add allowed traffic.
- Write a default deny policy for ingress, for egress and for both.
- Combine a `namespaceSelector` and a `podSelector` so they both must match.
- Tell the AND form and the OR form of a `from` list apart.
- Allow a range of addresses with `ipBlock` and `except`, and a range of ports with `endPort`.

## Before You Start

The module playground is an isolated kind cluster. It runs the `probe` Deployment and Service and the `shuttle` client pod in `starfleet`, and the `drifter` client pod in `outpost`. You need the `astrona` command-line tool, `kubectl` and a working container engine. Select the playground's private kubeconfig before you run any command.

## Reading Order

1. Default Deny And Additive Policies
2. Peer Selectors, IP Blocks And Ports
3. Summary

The playground holds the starting state for both parts. Keep it open while you read.

<!-- astrona:playground -->
