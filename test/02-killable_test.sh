#!/bin/bash

# this test starts a background task that sleeps and then writes to the logfile.
# the test passes if the background process is killed before it writes.

set -e
. test/test-helper.sh
prepare_files a.pid a.log

# 'launcher' should come before 'task' in the logfile
bin/backgrounded a.pid a.log 'echo start >> a.log; sleep 10; echo task'

block_until a.log contains start

echo 'double the killer' >> a.log
bin/kill_background_task a.pid > /dev/null

block_until a.pid does_not_exist

expected="start
double the killer"

# some systems output 'Terminated: 15' when the process is terminated, others don't.
actual="$(cat a.log | grep -v '^Terminated')"
check_result "$actual" "$expected"
