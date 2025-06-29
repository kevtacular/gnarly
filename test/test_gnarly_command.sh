#!/bin/bash

source common.sh

# Command execution tests
test_gnarly_simple_command() {
    gnarly init > /dev/null
    result=$(hello)
    assertEquals "Should execute simple command" "Hello, Gnarly!" "$result"
}

test_gnarly_script_command() {
    gnarly init > /dev/null
    cat > $GNARLY_CONFIG_DIR/bash.yml << EOF
commands:
  testscript:
    script: |
      echo "Line 1"
      echo "Line 2"
EOF
    expected=$'Line 1\nLine 2'
    result=$(testscript)
    assertEquals "Should execute multi-line script" "$expected" "$result"
}

test_gnarly_command_not_found() {
    result=$(nonexistent_command 2>&1)
    assertContains "Should handle nonexistent commands" "$result" "command not found"
}

# Load and run the tests
source "$SHUNIT_HOME/shunit2"