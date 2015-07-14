# This file provides some utilities to make testing easier


# Call this funciton with the names of the files that your test will use.
# It ensures that they don't exist when the test starts
# and that they're deleted when the test completes with no error.
prepare_files() {
  # filenames can't contain whitespace
  rm -f $@
  test_files+=" $@"
}


# if you use this function, it needs to be the final line in your file.
# otherwise your test's exit status may not be set properly.
check_result() {
  if [ "$expected" == "$actual" ]; then
    rm -f $test_files
    echo -n '.'
    # need trailing newline unless we were launched by run-tests.sh
    [ -n "$test_environment" ] || echo
  else
    echo
    echo "$0 GOT <<"
    echo "$actual"
    echo ">> BUT EXPECTED <<"
    echo "$expected"
    echo ">>"
    exit 1
  fi
}
