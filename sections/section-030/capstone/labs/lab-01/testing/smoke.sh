#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-030-capstone-030" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
lab_directory="$(cd "$(dirname "$0")/.." && pwd)"
start_failed=0
for check in "$lab_directory"/validation/*.sh; do
  bash "$check" >/dev/null 2>&1 || start_failed=1
done
if [[ $start_failed -eq 0 ]]; then
  printf 'Starting state unexpectedly passes every check\n' >&2
  exit 1
fi
bash "$lab_directory/solution/apply.sh"
for attempt in 1 2 3 4 5 6 7 8 9 10; do
  failed=0
  for check in "$lab_directory"/validation/*.sh; do
    bash "$check" >/dev/null 2>&1 || failed=1
  done
  if [[ $failed -eq 0 ]]; then exit 0; fi
  sleep 3
done
printf 'Reference result did not pass within the bounded retry period\n' >&2
exit 1
