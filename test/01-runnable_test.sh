#!/bin/bash

# this test starts a background task that sleeps and then writes to the logfile.
# if the foreground writes complete before the background, the test passes.


. test/test-helper.sh
prepare_files a.log

# processes are running concurrently if 'launcher' appears before 'task'
bin/start_background_task a.pid a.log 'sleep 0.1; echo task'
echo launcher >> a.log

# wait for subprocess to start
while [ ! -f a.pid ]; do sleep 0.1; done
# wait for subprocess to stop (on mac it's at least 0.5 seconds)
while [ -f a.pid ]; do sleep 0.1; done

expected="launcher
task"

actual="$(cat a.log)"
check_result "$actual" "$expected"
