# This file provides some utilities to make testing easier

# ensures these files don't exist when the test starts
# and that they're deleted when the test completes with no error
prepare_files() {
  # filenames can't contain whitespace
  rm -f $@
  test_files+=" $@"
}

check_result() {
  if [ "$expected" == "$actual" ]; then
    rm -f $test_files
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
}
