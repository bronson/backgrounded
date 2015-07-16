#!/bin/bash

# Ensure we can kill tasks that don't want to be killed

# this test starts a background task that sleeps and then writes to the logfile.
# the test passes if the background process is killed before it writes.

set -e
. test/test-helper.sh
prepare_files test-task.pid test-task.log

# 'launcher' should come before 'task' in the logfile
bin/backgrounded test-task 'trap "" INT TERM; echo start; sleep 1000; echo better-not-happen'

block_until test-task.log contains start

echo 'double the killer' >> test-task.log
bin/backgrounded kill test-task > /dev/null

block_until test-task.pid does_not_exist

expected="start
double the killer"

# some systems output 'Terminated: 15' when the process is terminated, others don't.
actual="$(cat test-task.log | grep -v '^Terminated')"

check_result "$actual" "$expected"
