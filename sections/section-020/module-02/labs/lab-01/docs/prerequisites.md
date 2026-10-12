---
draft: true
exam_objectives:
- Provide and troubleshoot access to applications via services
---
# Before You Start

You need Astrona CLI, kubectl, Python 3 and a working Podman engine. Astrona creates a separate kind environment for this lab and provides its private kubeconfig. The pinned practice node version is Kubernetes 1.35.0; this is a practice baseline rather than an exam-version parity claim.

The platform starts this lab from its launch action. For a local author run, start the saved lab directory with `astrona run -c`, then obtain the kubeconfig with `astrona kubeconfig ats-030-lab-020-02-01`. Select it before any cluster command. The expected context is `kind-astro-ats-030-lab-020-02-01`.

The starting Service is deliberately broken. The application listener and DNS must work before the learner begins. Grading runs in this isolated cluster; it does not write to unrelated environments.
