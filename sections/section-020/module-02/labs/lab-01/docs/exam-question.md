---
draft: true
exam_objectives:
- Provide and troubleshoot access to applications via services
---
# Repair A Service Target Port

The `shuttle` Pod in `starfleet` must reach the `probe` application through its existing Service. The application has two healthy replicas, but the Service request fails.

## Objective

Restore client access by correcting the Service's backend port relationship.

## Prerequisites

You can inspect a Service, Pod labels and EndpointSlices with kubectl. Use only this lab's private kubeconfig. The lab has an independent kind cluster and does not reuse the module playground.

## Starting state

The `probe` Deployment maintains two application replicas. The internal Service selects them and exposes TCP port 80. The `shuttle` client and the application are running. The environment contains an intentional Service port-mapping fault.

After the lab launch, select its private connection from your host shell:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-030-lab-020-02-01)"
kubectl config current-context
```

Confirm the context is `kind-astro-ats-030-lab-020-02-01` before any resource changes.

## Required result

Preserve the Service name `probe`, namespace `starfleet`, ClusterIP type and client-facing TCP port 80. Preserve its selector `app: probe` and `release: probe`, and keep two healthy application replicas. Correct the backend mapping so the existing application listener receives the request. The `shuttle` Pod must receive the version-one application response through the existing Service on port 80.

Change the Service. Do not alter the application image, process, client or replica count to work around the fault.

## Verify the result

Inspect the corrected mapping and ready endpoints, then make a bounded request from the original client. Grading checks the required Service fields, two ready and available replicas, and that client request. A direct request to a Pod address alone does not satisfy this task.
