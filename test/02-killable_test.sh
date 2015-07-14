#!/bin/bash

# this test starts a background task that sleeps and then writes to the logfile.
# the test passes if the background process is killed before it writes.

set -e
. test/test-helper.sh
prepare_files a.log

# 'launcher' should come before 'task' in the logfile
bin/backgrounded a.pid a.log 'echo start >> a.log; sleep 10; echo task'

# wait for subprocess to log its start
while [ ! -f a.log ]; do sleep 0.1; done
while ! grep -q start a.log; do sleep 0.1; done

echo 'double the killer' >> a.log
bin/kill_background_task a.pid > /dev/null

# wait for subprocess to stop (on mac it's at least 0.5 seconds)
while [ -f a.pid ]; do sleep 0.1; done

expected="start
double the killer"

# some systems output 'Terminated: 15' when the process is terminated, others don't.
actual="$(cat a.log | grep -v '^Terminated')"
check_result "$actual" "$expected"
