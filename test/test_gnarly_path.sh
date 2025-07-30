#!/bin/bash

source common.sh

# Helper function to test finding the config file in GNARLY_PATH
_do_path_test() {
    local expect_to_find="$1"
    
    gfile=$(realpath ".gnarly.yml")
    touch "$gfile"

    mkdir subdir
    pushd subdir > /dev/null
    _gnarly_find_cfg_file

    if [ "$expect_to_find" = "yes" ]; then
        assertEquals "Expected GNARLY_CFG_FILE to be found." "$gfile" "$GNARLY_CFG_FILE"
        assertEquals "Expected GNARLY_CFG_DIR to be found." "$(dirname "$gfile")" "$GNARLY_CFG_DIR"
    else
        assertEquals "Expected GNARLY_CFG_FILE to be empty." "$GNARLY_CFG_FILE" ""
        assertEquals "Expected GNARLY_CFG_DIR to be empty." "$GNARLY_CFG_DIR" ""
    fi

    popd > /dev/null

    rmdir subdir
}

# Test that we can find the config file in the first path of GNARLY_PATH
test_when_in_first_dir() {
    export GNARLY_PATH="$PWD:/nonexistent/path:/another/nonexistent/path"
    _do_path_test yes
}

# Test that we can find the config file in the middle path of GNARLY_PATH
test_when_in_middle_dir() {
    export GNARLY_PATH="/nonexistent/path:$PWD:/another/nonexistent/path"
    _do_path_test yes
}

# Test that we can find the config file in the second path of GNARLY_PATH
test_when_in_last_dir() {
    export GNARLY_PATH="/nonexistent/path:/another/nonexistent/path:$PWD"
    _do_path_test yes
}

# Test that we do not find the config file if not in a gnarly path
test_not_in_path() {
    export GNARLY_PATH="/nonexistent/path:/another/nonexistent/path"
    _do_path_test no
}


# Test that we do not find the config file if it is in a parent of a directory
# in the GNARLY_PATH
test_in_parent_dir() {
    export GNARLY_PATH="$PWD/subdir"
    _do_path_test no
}

source $SHUNIT_HOME/shunit2
