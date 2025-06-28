# Shared by all tests

script_dir=$(dirname "$(realpath "$0")")

# Ensure SHUNIT_HOME is set to the shunit2 directory
if [ "$SHUNIT_HOME" = "" ]; then
  shunit_dir=$(find "$script_dir" -maxdepth 1 -type d -name 'shunit2-*' | head -n 1)

  if [ -n "$shunit_dir" ]; then
    export SHUNIT_HOME="$shunit_dir"
  else
    echo "SHUNIT_HOME environment variable is not set. Please set this to the location of shunit2 before running tests."
    exit 1
  fi
fi

# Source the gnarly script
source $script_dir/../gnarly.sh

# Test suite setup
setUp() {
    # Check if yq is installed
    if ! command -v yq >/dev/null 2>&1; then
        echo "Error: yq is required but not found in PATH"
        echo "Please install yq: https://github.com/mikefarah/yq/#install"
        exit 1
    fi

    TEST_ROOT=$(realpath "$(dirname "$0")")

    # Source the gnarly script
    source "$(dirname "$0")/../gnarly.sh"

    # Create a temporary test directory
    # TEST_DIR=$(mktemp -d --tmpdir=/tmp gnarly-XXXX)
    TEST_DIR=testdir
    mkdir -p "$TEST_DIR/$GNARLY_CONFIG_DIR"
    cd "$TEST_DIR" || exit 1
}

# Test suite teardown
tearDown() {
    # Return to the test root directory
    cd $TEST_ROOT > /dev/null

    # Clean up temporary directory
    rm -rf "$TEST_DIR"
}