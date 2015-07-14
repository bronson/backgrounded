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


# ensures these files don't exist when the test starts
# and that they're deleted when the test completes with no error
prepare_files() {
  # filenames can't contain whitespace
  rm -f $@
  test_files+=" $@"
}

check_result() {
  if [ "$expected" == "$actual" ]; then
    rm -f $test_files
    echo -n '.'
  else
    echo
    echo "$0 GOT <<"
    echo "$actual"
    echo ">> BUT EXPECTED <<"
    echo "$expected"
    echo ">>"
    exit 1
  fi
}

export -f prepare_files check_result


[ -d bin ] || die "you must run tests from the root of the repository"

export PATH="./bin:$PATH"

for test in test/*_test.sh; do
  ((tests++));
  "$test" || ((failures++))
done

printf "\n$tests test$(plural $tests) run, ${failures-0} failure$(plural $failures).\n\n"
