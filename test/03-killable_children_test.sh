#!/bin/bash

# this test fires off some children that sleep and then write...
# if the children don't get killed before they write, the test fails.

set -e
rm -f a.log

cat > task <<EOL
  echo start >> a.log
EOL

bash -c "bin/start_background_task a.pid a.log 'exec bash task'"

# wait for subprocess to log its start
while ! grep -q start a.log; do sleep 0.1; done

echo 'double the killer' >> a.log
bash -c "bin/kill_background_task a.pid" > /dev/null

# wait for subprocess to stop (on mac it's at least 0.5 seconds)
while [ -f a.pid ]; do sleep 0.1; done

expected="start
double the killer"
# Terminated: 15"   # not sure about this line...  is it an OSX/BSDish thing?

actual="$(cat a.log)"
rm task a.log


if [ "$expected" == "$actual" ]; then
  echo -n '.'
else
  echo
  echo "$0 GOT <<"
  echo "$actual"
  echo ">> BUT EXPECTED <<"
  echo "$expected"
  echo ">>"
  exit 1
fi
