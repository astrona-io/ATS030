# Section 030 Capstone: Publish Two Services Through One TLS Ingress

Integration lab for Ingress: route two paths of one host to two Services and terminate TLS. The lab uses its own pinned kind cluster named `ats-030-capstone-030`. UNTESTED: built from static checks only; the starting state, the reference solution and the validation scripts have not been run.

```sh
astrona validate -c .
astrona run -c .
astrona submit -c .
astrona destroy ats-030-capstone-030
```

Authors prove the reference solution with `astrona test -c .` and with `testing/smoke.sh`.
