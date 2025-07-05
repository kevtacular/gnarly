#!/bin/bash

source common.sh

# Show command tests
test_gnarly_show_simple() {
    gnarly init > /dev/null
    result=$(gnarly show hello)
    assertEquals "Should show simple command" 'echo "Hello, Gnarly!"' "$result"
}

test_gnarly_show_script() {
    gnarly init > /dev/null
    cat > .gnarly.yml << EOF
commands:
  testscript:
    script: |
      echo "Test"
      echo "Script"
EOF
    expected=$'script: |\n  echo "Test"\n  echo "Script"'
    result=$(gnarly show testscript)
    assertEquals "Should show script command" "$expected" "$result"
}

test_gnarly_show_nonexistent() {
    # Nonexistent gnarly config directory
    result=$(gnarly show nonexistent 2>&1)
    assertContains "Should handle nonexistent gnarly config directory" "$result" "No gnarly configuration found"

    # Existing gnarly config directory but nonexistent command
    gnarly init > /dev/null
    result=$(gnarly show nonexistent 2>&1)
    assertContains "Should handle nonexistent command" "$result" "Command not found"
}

# Load and run the tests
source "$SHUNIT_HOME/shunit2"