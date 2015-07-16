#!/bin/bash

# this test starts a background task that sleeps and then writes to the logfile.
# if the foreground writes complete before the background, the test passes.

set -e
. test/test-helper.sh
prepare_files a.log

# processes are running concurrently if 'launcher' appears before 'task'
bin/backgrounded a.pid a.log 'sleep 0.1; echo task'
echo launcher >> a.log

block_until_task_starts a.pid
block_until_task_stops a.pid

expected="launcher
task"

actual="$(cat a.log)"
check_result "$actual" "$expected"
