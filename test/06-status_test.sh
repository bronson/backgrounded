#!/bin/bash

# Ensure we can run tasks in the background

# this test starts a background task that sleeps and then writes to the logfile.
# if the foreground writes complete before the background, the test passes.

set -e
. test/test-helper.sh
prepare_files backgrounded-task.pid backgrounded-task.log

bin/backgrounded status >> backgrounded-task.log
echo "result was $?" >> backgrounded-task.log

bin/backgrounded -q 'sleep 1; echo will-not-happen'

block_until backgrounded-task.pid exists

bin/backgrounded status >> backgrounded-task.log
echo "result was $?" >> backgrounded-task.log

bin/backgrounded kill > /dev/null
block_until backgrounded-task.pid does_not_exist

bin/backgrounded status >> backgrounded-task.log
echo "result was $?" >> backgrounded-task.log

# currently we always return 0 for calls to status
# we should probably make this more useful at some point
expected="backgrounded-task.pid isn't running
result was 0
backgrounded-task.pid is running: THEPID
result was 0
backgrounded-task.pid isn't running
result was 0"

actual="$(cat backgrounded-task.log | grep -v '^Terminated' | sed 's/is running: [0-9]*/is running: THEPID/')"

check_result "$actual" "$expected"
