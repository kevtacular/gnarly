#!/bin/bash

source common.sh

create_gnarly_args_file() {
    cat > $GNARLY_CONFIG_DIR/bash.yml << EOF
commands:
  greet:
    args:
      - G_NAME
    script: |
      echo "Hello, \$G_NAME!"
EOF
}

test_gnarly_command_with_args() {
    create_gnarly_args_file
    result=$(greet "World")
    assertEquals "Should handle command arguments" "Hello, World!" "$result"
}

test_gnarly_missing_args() {
    gnarly init > /dev/null
    create_gnarly_args_file

    result=$(greet 2>&1)
    assertContains "Should error on missing arguments" "$result" "Missing required argument"
}

# Load and run the tests
source "$SHUNIT_HOME/shunit2"