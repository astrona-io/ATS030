# Create Three Service Types For One Application

Create a NodePort, a headless and an ExternalName Service for one Deployment. The lab uses its own pinned kind cluster named `ats-030-lab-020-03-01`. UNTESTED: built from static checks only; the starting state, the reference solution and the validation scripts have not been run.

```sh
astrona validate -c .
astrona run -c .
astrona submit -c .
astrona destroy ats-030-lab-020-03-01
```

Authors prove the reference solution with `astrona test -c .` and with `testing/smoke.sh`.
