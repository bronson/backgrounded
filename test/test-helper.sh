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


block_until_timeout() {
  sleep 0.1
  if [ "$(date +'%s')" -ge "$block_until_timeout" ]; then
    echo "$0: '$*' timed out!"
    exit 2
  fi
}


block_until() {
  block_until_timeout="$(($(date +'%s') + 10))"  # this number is the timeout in seconds
  case "$2" in
    exists)
      while [ ! -f "$1" ]; do block_until_timeout "$@"; done
      ;;
    does_not_exist|goes_away)
      while [ -f "$1" ]; do block_until_timeout "$@"; done
      ;;
    contains)
      block_until "$1" exists
      while ! grep -q "$3" "$1"; do block_until_timeout "$@"; done
      ;;
    *)
      echo "uknown block_until $2"
      exit 1
  esac
}
