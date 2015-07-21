#!/bin/bash

status=0
test=test/run-tests.sh

# download the bash binaries
for version in $BASHES; do
  wget -nv https://raw.githubusercontent.com/bronson/bashes/master/$(arch)/bash-$version
  [ ! -f bash-$version ] && exit 1
  chmod a+x bash-$version
done

# run the tests on each binary
for version in $BASHES; do
  echo
  echo ==================
  echo Bash $version
  echo ==================
  ./bash-$version "$test" || status=$?
done

exit $status
