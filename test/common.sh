# Shared by all tests

script_dir=$(dirname "$(realpath "$0")")

if [ "$SHUNIT_HOME" = "" ]; then
  shunit_dir=$(find "$script_dir" -maxdepth 1 -type d -name 'shunit2-*' | head -n 1)

  if [ -n "$shunit_dir" ]; then
    export SHUNIT_HOME="$shunit_dir"
  else
    echo "SHUNIT_HOME environment variable is not set. Please set this to the location of shunit2 before running tests."
    exit 1
  fi
fi

source $script_dir/../gnarly.sh
