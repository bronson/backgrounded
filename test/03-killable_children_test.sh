#!/bin/bash

# this test fires off some children that sleep and then write...
# if the children don't get killed before they write, the test fails.

set -e
. test/test-helper.sh
prepare_files task a.log

cat > task <<EOL
  echo start >> a.log
EOL

bin/backgrounded a.pid a.log 'exec bash task'

block_until a.log contains start

echo 'double the killer' >> a.log
bin/kill_background_task a.pid > /dev/null

block_until a.pid does_not_exist

expected="start
double the killer"

# some systems output 'Terminated: 15' when the process is terminated, others don't.
actual="$(cat a.log | grep -v '^Terminated')"
check_result "$actual" "$expected"
