#!/bin/bash

# Justification:
# Writing this is probably the final nail in the coffin for tmtest.
# I tried to like shunit2 before realizing it would take less time just
# to roll my own.  Good overview of testing in the shell:
# https://blog.scraperwiki.com/2012/12/how-to-test-shell-scripts/
# oo, interesting: https://github.com/sstephenson/bats

die() {
  echo $1 >&2
  exit 1
}

plural() {
  [ ${1-0} -ne 1 ] && echo s
}

[ -d bin ] || die "you must run tests from the root of the repository"

export PATH="./bin:$PATH"
export test_environment=1  # tell the tests there's a test runner

for test in test/*_test.sh; do
  ((tests++));
  "$test" || ((failures++))
done

printf "\n$tests test$(plural $tests) run, ${failures-0} failure$(plural $failures).\n\n"
[ -z "$failures" ] || exit 1
