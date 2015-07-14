#!/bin/bash

# this test fires off some children that sleep and then write...
# if the children don't get killed before they write, the test fails.

. test/test-helper.sh
prepare_files task a.log

cat > task <<EOL
  echo start >> a.log
EOL

bin/start_background_task a.pid a.log 'exec bash task'

# wait for subprocess to log its start
while ! grep -q start a.log; do sleep 0.1; done

echo 'double the killer' >> a.log
bin/kill_background_task a.pid > /dev/null

# wait for subprocess to stop (on mac it appears to be at least 0.5 seconds)
while [ -f a.pid ]; do sleep 0.1; done

expected="start
double the killer"

# some systems output 'Terminated: 15' when the process is terminated, others don't.
actual="$(cat a.log | grep -v 'Terminated: 15')"
check_result "$actual" "$expected"
