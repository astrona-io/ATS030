# Section 020 Capstone: Repair And Expose An Application With Services

Integration lab for Services: repair a Service with a wrong selector and target port, then add a NodePort, a headless and an ExternalName Service. The lab uses its own pinned kind cluster named `ats-030-capstone-020`. UNTESTED: built from static checks only; the starting state, the reference solution and the validation scripts have not been run.

```sh
astrona validate -c .
astrona run -c .
astrona submit -c .
astrona destroy ats-030-capstone-020
```

Authors prove the reference solution with `astrona test -c .` and with `testing/smoke.sh`.
