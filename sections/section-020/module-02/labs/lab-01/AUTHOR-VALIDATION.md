# Author validation

Built for astrona CLI `developer` using the vendored blueprint selected by the astrona-course-lab skill on 2026-10-12. The installed binary accepts the older `metadata.docs.examQuestion` and `metadata.docs.guide` fields. The task and solution are explicitly registered in the course manifest because its content parser uses different canonical documentation keys.

Static evidence:

- Skill structural validator: passed.
- Installed `astrona validate`: passed with zero problems.
- Bootstrap, reference solution, grader and documented shell syntax: passed.
- Offline grader regression suite: six tests passed, including the starting fault, wrong selector or client port, missing ready capacity, failed or wrong application responses, and refusal of another cluster context. Both named and numeric correct target ports are accepted.
- Course task, lab and solution ordering and draft exclusions: checked against the actual content parser.

The offline suite substitutes kubectl responses to test decision logic. Those responses are test fixtures, not live Kubernetes transcripts.

`astrona content validate ats` reports that this content validator is not implemented. The separate structural validator and `astrona validate` provide the available static checks.

Live lifecycle testing remains pending. `astrona check` found the tools but could not access a working container engine from this session; kind's Podman connection failed with `operation not permitted`. No lab environment was created by that attempted check.

From the repository root, with a working local container engine, run:

```sh
astrona check
astrona test -c sections/section-020/module-02/labs/lab-01 --junit-xml=/tmp/ats030-service-lab.xml
```

Review the actual result before removing draft flags. The lab owns a separate context and teardown removes only its environment.
