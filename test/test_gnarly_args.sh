#!/bin/bash

source common.sh

create_gnarly_args_file() {
    cat > .gnarly.yml << EOF
commands:
  greet:
    args:
      - G_NAME
    script: |
      echo "Hello, \$G_NAME!"
EOF
}

create_gnarly_invalid_args_file() {
    cat > .gnarly.yml << EOF
commands:
  greet_invalid:
    args:
      - G_NAME-invalid
    script: |
      echo "Hello, \$G_NAME-invalid!"
EOF
}

test_command_with_args() {
    create_gnarly_args_file
    result=$(greet "World")
    assertEquals "Should handle command arguments" "Hello, World!" "$result"
}

test_missing_args() {
    create_gnarly_args_file
    result=$(greet 2>&1)
    assertContains "Should error on missing arguments" "$result" "Missing required argument"
}

test_invalid_arg_name() {
    create_gnarly_invalid_args_file
    result=$(greet_invalid "World" 2>&1)
    assertContains "Should error on invalid argument name" "$result" "Invalid argument name"
}

# Load and run the tests
source "$SHUNIT_HOME/shunit2"
