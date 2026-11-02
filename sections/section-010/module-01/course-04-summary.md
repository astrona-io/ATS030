---
draft: true
exam_objectives:
- Demonstrate basic understanding of NetworkPolicies
---
# Summary

NetworkPolicy declares allowed connection relationships for selected Pods when the network implementation enforces them. Directional isolation and additive grants determine the effective allowed traffic.

Peer selectors, ports and required dependencies must be read together. A declared policy is not proof of enforcement, and permitted transport does not establish application identity or protect every allowed operation.

NetworkPolicy selection and rule structure determine declared allowances, while an enforcing implementation determines effective traffic behavior. Combined selectors, alternative peers and additive policies need evaluation against actual labels and both connection endpoints.

<!-- astrona:playground:destroy -->
