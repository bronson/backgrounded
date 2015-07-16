#!/bin/bash

# Ensure we handle invalid pidfiles ok

# this test starts a background task that sleeps and then writes to the logfile.
# if the foreground writes complete before the background, the test passes.

set -e
. test/test-helper.sh
prepare_files pidfile.pid output.log

echo '<-o->"$@$"(-o-)' > pidfile.pid
bin/backgrounded status -p pidfile.pid >> output.log

expected="pidfile.pid isn't running"
actual="$(cat output.log)"
check_result "$actual" "$expected"
