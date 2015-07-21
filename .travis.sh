#!/bin/bash

status=0

for b in $BASHES; do
    echo
    echo ==================
    echo $b
    echo ==================
    $b test/run-tests.sh || status=$?
done

exit $status
