---
draft: true
exam_objectives:
- Demonstrate basic understanding of NetworkPolicies
---
# Summary

A pod accepts and makes every connection until a NetworkPolicy selects it for a direction. After that, only traffic that some selecting policy allows can pass in that direction. Policies never subtract: the allowed traffic is the union of all rules, and both ends of a connection must allow it.

A default deny policy uses an empty `podSelector`, a `policyTypes` list and no rules. It closes a namespace for ingress, egress or both. A default deny for egress also blocks DNS, so name resolution needs its own allowance.

A peer is named by pod labels, namespace labels or an address block. A `namespaceSelector` and a `podSelector` in one list entry must both match. In two entries, either one is enough. Ports narrow a rule by protocol, number and range with `endPort`, and they name the port the pod listens on. Address blocks suit addresses outside the cluster.

- A blocked connection times out. A refused connection means the pod answered.
- A policy cannot deny what another policy allows.
- One dash decides AND or OR.

<!-- astrona:playground:destroy -->
