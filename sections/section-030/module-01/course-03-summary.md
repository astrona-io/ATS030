---
draft: true
exam_objectives:
- Use Ingress rules to expose applications
---
# Summary

Ingress resources declare host and path routing to Service backends, while a suitable controller implements the traffic path. Class selection and reachable entry infrastructure are independent requirements.

Backend references use the Service port contract. Path matching does not universally rewrite the application path, and external encrypted transport does not automatically encrypt the controller-to-backend connection.

External routing needs an active matching controller, correct host and path rules, a valid Service port and usable backends. Frontend TLS termination is a separate security boundary and does not automatically encrypt the backend hop.

<!-- astrona:playground:destroy -->
