#!/bin/bash

source common.sh

# Initialization tests
test_init() {
    result=$(gnarly init)
    assertTrue "Should create .gnarly.yml file" "[ -f .gnarly.yml ]"
    assertContains "Should echo what it's doing" "$result" "Creating"
}

test_init_existing() {
    gnarly init > /dev/null
    result=$(gnarly init 2>&1)
    assertContains "Should not overwrite existing config" "$result" "already exists"
}

# Load and run the tests
source "$SHUNIT_HOME/shunit2"