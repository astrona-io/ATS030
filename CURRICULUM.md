# Curriculum Coverage

Exam: Certified Kubernetes Application Developer (CKAD). Domain: Services and Networking (20%).

The [official objectives](https://training.linuxfoundation.org/certification/certified-kubernetes-application-developer-ckad/) were verified on 2026-10-11. Teaching structure is original; it does not add official exam requirements.

| Section | Official objective | Modules |
| --- | --- | --- |
| 010 | Demonstrate basic understanding of NetworkPolicies | 3 |
| 020 | Provide and troubleshoot access to applications via services | 3 |
| 030 | Use Ingress rules to expose applications | 2 |

| Section / module | Module | Teaching lessons |
| --- | --- | --- |
| 010 / 01 | NetworkPolicy Selection And Allowed Connections | NetworkPolicy And Allowed Connections; Traffic Isolation And Allowed Peers |
| 010 / 02 | Dependency-Aware Network Isolation | DNS And Service Discovery |
| 010 / 03 | Default Deny, Peer Selectors And IP Blocks | Default Deny And Additive Policies; Peer Selectors, IP Blocks And Ports |
| 020 / 01 | Services, Ports And Ready Backends | Selectors, Ports And Backends; Pod Addresses And Network Implementation |
| 020 / 02 | Troubleshooting A Service Request | Tracing A Service Request |
| 020 / 03 | Service Types, Headless Services And Service DNS | Service Types: ClusterIP, NodePort And LoadBalancer; Headless Services, ExternalName And Service DNS |
| 030 / 01 | Ingress Routing And TLS Contracts | Matching Ingress Hosts, Paths And Service Backends |
| 030 / 02 | External Request Diagnosis | Tracing An External Request To The Application |

The module goals and adaptation sources are recorded in AUTHORING.yaml. Every official objective is covered. Each section starts with an introduction, and each module ends with a summary. YAML banks follow the relevant summary and remain separate from the Markdown manifest.

This is a reading-only draft. No new labs, playgrounds, command output or runtime verification are included. ATP006 publication remains draft.

## Hands-On Expansion

Playgrounds and guided practical readings were added on 2026-10-12. Every existing module retains its concept readings and gains one practical reading before its renumbered summary. YAML bank placement follows the new summary path. Official weights, objective IDs and ATP006 links are unchanged. Runtime verification is pending; static checks do not establish successful cluster execution.

## Graded Lab Expansion

Every active module includes a draft independent graded lab. This course has 7 active graded labs, registered after the readings they practise. Each has its own cluster, task, solution, context guards, reference repair and behavior grader. Static and offline checks pass. Live verification remains pending because the authoring session cannot access the Podman socket. The installed CLI's configuration validator is separately blocked by its local-state maintenance lock.

| Module | Labs in teaching order |
| --- | --- |
| 010/01 | Allow One Peer And Deny Another |
| 010/02 | Allow DNS And One Application Dependency |
| 020/01 | Repair A Service Selector |
| 020/02 | Repair A Service Target Port |
| 030/01 | Route A Matching Host Through Ingress |
| 030/02 | Repair A Missing Ingress Backend; Verify TLS Termination And Server Identity |
