# Section 010 Capstone: Isolate A Namespace In Both Directions

Integration lab for NetworkPolicy: remove a permissive policy, close both directions and open only what the application needs. The lab uses its own pinned kind cluster named `ats-030-capstone-010`. UNTESTED: built from static checks only; the starting state, the reference solution and the validation scripts have not been run.

```sh
astrona validate -c .
astrona run -c .
astrona submit -c .
astrona destroy ats-030-capstone-010
```

Authors prove the reference solution with `astrona test -c .` and with `testing/smoke.sh`.
