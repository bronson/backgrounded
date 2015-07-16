#!/bin/bash

# this test starts a background task that sleeps and then writes to the logfile.
# if the foreground writes complete before the background, the test passes.

set -e
. test/test-helper.sh
prepare_files background-task.pid backgrounded-task.log

# if 'launcher' appears before 'task' then processes ran concurrently
bin/backgrounded 'sleep 0.1; echo task'
echo launcher >> backgrounded-task.log

block_until backgrounded-task.pid exists
block_until backgrounded-task.pid does_not_exist

expected="launcher
task"

actual="$(cat backgrounded-task.log)"

check_result "$actual" "$expected"
