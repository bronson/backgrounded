#!/bin/bash

# this test starts a background task that sleeps and then writes to the logfile.
# the test passes if the background process is killed before it writes.


set -e
rm -f a.log

# 'launcher' should come before 'task' in the logfile
bash -c "bin/start_background_task a.pid a.log 'echo start >> a.log; sleep 10; echo task'"

# wait for subprocess to log its start
while ! grep -q start a.log; do sleep 0.1; done

echo 'double the killer' >> a.log
bash -c "bin/kill_background_task a.pid" > /dev/null

# wait for subprocess to stop (on mac it's at least 0.5 seconds)
while [ -f a.pid ]; do sleep 0.1; done

expected="start
double the killer
Terminated: 15"   # not sure about this line...  is it an OSX/BSDish thing?

actual="$(cat a.log)"
rm a.log
check_result "$actual" "$expected"
