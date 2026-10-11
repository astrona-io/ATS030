# Services and Networking (ATS030)

Certified Kubernetes Application Developer (CKAD): Services and Networking, worth 20% of the curriculum and part of ATP006.

Each section has an introduction. Each module combines detailed concept readings, an ungraded isolated playground, guided practical work and a closing summary. YAML knowledge checks remain separately indexed. Technical content stays draft for review. New graded labs are not included.

## Course Outline

| Section / module | Module | Concept and practical readings |
| --- | --- | --- |
| 010 / 01 | NetworkPolicy Selection And Allowed Connections | NetworkPolicy And Allowed Connections; Traffic Isolation And Allowed Peers; Enforce Ingress Isolation And One Allowed Peer |
| 010 / 02 | Dependency-Aware Network Isolation | DNS And Service Discovery; Allow DNS And The Application As Separate Dependencies |
| 020 / 01 | Services, Ports And Ready Backends | Selectors, Ports And Backends; Pod Addresses And Network Implementation; Repair A Service Target Port |
| 020 / 02 | Troubleshooting A Service Request | Tracing A Service Request; Trace A Missing Backend To Its Selector |
| 030 / 01 | Ingress Routing And TLS Contracts | Matching Ingress Hosts, Paths And Service Backends; Route A Host And Path Through An Ingress Controller |
| 030 / 02 | External Request Diagnosis | Tracing An External Request To The Application; Locate A Broken Ingress Backend Reference |

## Author Review

See [curriculum coverage](CURRICULUM.md), [primary sources](SOURCES.md), [assessment contracts](ASSESSMENTS.md) and [contribution guidance](CONTRIBUTING.md). Each playground has its own config, bootstrap, guide and author smoke script. Static checks passed; live execution remains pending because the authoring session cannot access the container engine. Retain that limitation until real runtime evidence is recorded.
