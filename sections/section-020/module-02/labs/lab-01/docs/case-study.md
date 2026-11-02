---
draft: true
exam_objectives:
- Provide and troubleshoot access to applications via services
---
# Diagnose A Service Request Failure

The shuttle Pod must reach probe without changing the public Service contract. Two application replicas are healthy, but the named access point fails.

Compare the Service selector with actual Pod labels. Compare its client port and target port with the application's listener. Then inspect ready endpoint addresses and ports to identify where the relationship breaks.

A selector change repairs only selection; a replica change repairs only capacity. Neither is the right correction for a healthy selected population paired with a wrong listener port. Verify through the same client after the focused correction.
