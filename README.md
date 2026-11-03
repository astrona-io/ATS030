# Services and Networking (ATS030)

Certified Kubernetes Application Developer (CKAD): Services and Networking, worth 20% of the curriculum and part of ATP006.

Each section has an introduction. Each module combines detailed concept readings, an ungraded isolated playground, guided practical work and a closing summary. YAML knowledge checks remain separately indexed. Technical content stays draft for review. Every active module includes a draft independent graded lab.

## Course Outline

| Section / module | Module | Concept and practical readings |
| --- | --- | --- |
| 010 / 01 | NetworkPolicy Selection And Allowed Connections | NetworkPolicy And Allowed Connections; Traffic Isolation And Allowed Peers; Enforce Ingress Isolation And One Allowed Peer |
| 010 / 02 | Dependency-Aware Network Isolation | DNS And Service Discovery; Allow DNS And The Application As Separate Dependencies |
| 010 / 03 | Default Deny, Peer Selectors And IP Blocks | Default Deny And Additive Policies; Peer Selectors, IP Blocks And Ports |
| 020 / 01 | Services, Ports And Ready Backends | Selectors, Ports And Backends; Pod Addresses And Network Implementation; Repair A Service Target Port |
| 020 / 02 | Troubleshooting A Service Request | Tracing A Service Request; Trace A Missing Backend To Its Selector |
| 020 / 03 | Service Types, Headless Services And Service DNS | Service Types: ClusterIP, NodePort And LoadBalancer; Headless Services, ExternalName And Service DNS |
| 030 / 01 | Ingress Routing And TLS Contracts | Matching Ingress Hosts, Paths And Service Backends; Route A Host And Path Through An Ingress Controller |
| 030 / 02 | External Request Diagnosis | Tracing An External Request To The Application; Locate A Broken Ingress Backend Reference |

## Author Review

See [curriculum coverage](CURRICULUM.md), [primary sources](SOURCES.md), [assessment contracts](ASSESSMENTS.md) and [contribution guidance](CONTRIBUTING.md). Each playground has its own config, bootstrap, guide and author smoke script. Static checks passed; live execution remains pending because the authoring session cannot access the container engine. Retain that limitation until real runtime evidence is recorded.

## Labs, Capstones And Quizzes

Every module has an ungraded playground and one graded lab. Every section ends with an advanced capstone lab and a section quiz. A final domain quiz closes the course. All 8 module labs and 3 capstones are registered after the readings they practise, and the quizzes are YAML files with `type: quiz` and a pass score of 70. Static checks pass (`astrona validate -c` on every lab and playground configuration, `bash -n` on every script, `ruby -ryaml` on every YAML file). UNTESTED: no lab or playground has been started, so live verification is pending.

| Module | Graded lab |
| --- | --- |
| 010/01 | Allow One Peer And Deny Another |
| 010/02 | Allow DNS And One Application Dependency |
| 010/03 | Default Deny With One Cross-Namespace Allow |
| 020/01 | Repair A Service Selector |
| 020/02 | Repair A Service Target Port |
| 020/03 | Create Three Service Types For One Application |
| 030/01 | Route A Matching Host Through Ingress |
| 030/02 | Repair A Missing Ingress Backend; Verify TLS Termination And Server Identity |

| Section | Capstone (advanced) | Quiz |
| --- | --- | --- |
| 010 | Isolate A Namespace In Both Directions | `sections/section-010/quiz.yaml` |
| 020 | Repair And Expose An Application With Services | `sections/section-020/quiz.yaml` |
| 030 | Publish Two Services Through One TLS Ingress | `sections/section-030/quiz.yaml` |

The final domain quiz is `sections/final-domain-quiz.yaml`.
