#!/bin/bash

# this test starts a background task that sleeps and then writes to the logfile.
# if the foreground writes complete before the background, the test passes.


set -e
rm -f a.log

# 'launcher' should come before 'task' in the logfile
bash -c "bin/start_background_task a.pid a.log 'sleep 0.1; echo task'"
echo launcher >> a.log

# wait for subprocess to start
while [ ! -f a.pid ]; do sleep 0.1; done
# wait for subprocess to stop (on mac it's at least 0.5 seconds)
while [ -f a.pid ]; do sleep 0.1; done

expected="launcher
task"

actual="$(cat a.log)"
rm a.log


if [ "$expected" == "$actual" ]; then
  echo -n '.'
else
  echo EXPECTED:
  echo "$expected"
  echo "ACTUAL:"
  echo "$actual"
  exit 1
fi
