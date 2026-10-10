# Curriculum Coverage

Exam: Certified Kubernetes Application Developer (CKAD). Domain: Services and Networking (20%).

The [official objectives](https://training.linuxfoundation.org/certification/certified-kubernetes-application-developer-ckad/) were verified on 2026-10-11. Teaching structure is original; it does not add official exam requirements.

| Section | Official objective | Modules |
| --- | --- | --- |
| 010 | Demonstrate basic understanding of NetworkPolicies | 2 |
| 020 | Provide and troubleshoot access to applications via services | 2 |
| 030 | Use Ingress rules to expose applications | 2 |

| Section / module | Module | Teaching lessons |
| --- | --- | --- |
| 010 / 01 | NetworkPolicy Selection And Allowed Connections | NetworkPolicy And Allowed Connections; Traffic Isolation And Allowed Peers |
| 010 / 02 | Dependency-Aware Network Isolation | DNS And Service Discovery |
| 020 / 01 | Services, Ports And Ready Backends | Selectors, Ports And Backends; Pod Addresses And Network Implementation |
| 020 / 02 | Troubleshooting A Service Request | Tracing A Service Request |
| 030 / 01 | Ingress Routing And TLS Contracts | Matching Ingress Hosts, Paths And Service Backends |
| 030 / 02 | External Request Diagnosis | Tracing An External Request To The Application |

The module goals and adaptation sources are recorded in AUTHORING.yaml. Every official objective is covered. Each section starts with an introduction, and each module ends with a summary. YAML banks follow the relevant summary and remain separate from the Markdown manifest.

This is a reading-only draft. No new labs, playgrounds, command output or runtime verification are included. ATP006 publication remains draft.
