#!/bin/bash

# Ensure that killing the task kills off the task's children too
#
# this test fires off some children that sleep and then write...
# if the children don't get killed before they write, the test fails.

set -e
. test/test-helper.sh
prepare_files task a.pid a.log


cat > task <<EOL
  bash -c 'echo start child; sleep 0.3; echo child did-not-happen' &
EOL

bin/backgrounded -p a.pid -o a.log 'bash task; sleep 0.3; echo parent did-not-happen'

block_until a.log contains 'start child'

echo 'double the killer' >> a.log
bin/backgrounded kill -p a.pid > /dev/null

block_until a.pid does_not_exist

# give the children time to run to completion
sleep 0.6

expected="start child
double the killer"

# some systems output 'Terminated: 15' when the process is terminated, others don't.
actual="$(cat a.log | grep -v '^Terminated')"
check_result "$actual" "$expected"
