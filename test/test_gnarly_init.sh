#!/bin/bash

source common.sh

# Initialization tests
test_gnarly_init() {
    result=$(gnarly init)
    assertTrue "Should create gnarly config directory" "[ -d $GNARLY_CONFIG_DIR ]"
    assertTrue "Should create bash.yml file" "[ -f $GNARLY_CONFIG_DIR/bash.yml ]"
    assertContains "Should echo what it's doing" "$result" "Creating"
}

test_gnarly_init_existing() {
    gnarly init > /dev/null
    result=$(gnarly init 2>&1)
    assertContains "Should not overwrite existing config" "$result" "already exists"
}

# Load and run the tests
source "$SHUNIT_HOME/shunit2"