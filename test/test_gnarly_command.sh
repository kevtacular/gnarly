#!/bin/bash

source common.sh

# Command execution tests
test_simple_command() {
    gnarly init > /dev/null
    result=$(gecho)
    assertEquals "Should execute simple command" "gecko" "$result"
}

test_script_command() {
    cat > .gnarly.yml << EOF
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

test_command_not_found() {
    result=$(nonexistent_command 2>&1)
    assertContains "Should handle nonexistent commands" "$result" "command not found"
}

# Load and run the tests
source "$SHUNIT_HOME/shunit2"