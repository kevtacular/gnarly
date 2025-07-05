#!/bin/bash

source common.sh

create_gnarly_file_root() {
    cat > .gnarly.yml << EOF
commands:
  hello: echo "Hello, Gnarly!"
  kerninfo:
    script: |
      echo "Kernel Info"
      uname -r
      uname -v
  sysinfo:
    script: |
      echo "=== System Information ==="
      uname -a
      echo -e "\n=== CPU Info ==="
      lscpu | grep -E "^(Model name|Architecture|CPU\(s\))"
      echo -e "\n=== Memory Info ==="
      free -h
      echo -e "\n=== Disk Usage ==="
      df -h
      echo -e "\n=== Distribution Info ==="
      cat /etc/os-release | grep -E "^(NAME|VERSION)="
EOF
}

create_gnarly_file_level1() {
    mkdir -p level1
    cat > level1/.gnarly.yml << EOF
commands:
  cpuinfo: echo "CPU Info"
EOF
}

create_gnarly_file_level2() {
    mkdir -p level1/level2
    cat > level1/level2/.gnarly.yml << EOF
commands:
  meminfo: echo "Memory Info"
EOF
}

create_gnarly_file_level3() {
    mkdir -p level1/level2/level3
    cat > level1/level2/level3/.gnarly.yml << EOF
commands:
  diskinfo: df -h
  distroinfo: |
    cat /etc/os-release | grep -E "^(NAME|VERSION)="
  kerninfo: uname -r
  meminfo: free -h
EOF
}

# Basic functionality tests
test_gnarly_list_commands() {
    create_gnarly_file_root
    expected=$'hello\nkerninfo\nsysinfo'
    result=$(gnarly)
    assertEquals "Should list all available commands" "$expected" "$result"
}

test_gnarly_verbose_list() {
    create_gnarly_file_root
    expected=$'hello: echo "Hello, Gnarly!"\nkerninfo: [script]\nsysinfo: [script]'
    result=$(gnarly -v)
    assertEquals "Should list commands with descriptions" "$expected" "$result"
}

# Directory hierarchy tests
test_gnarly_level1() {
    create_gnarly_file_root
    create_gnarly_file_level1
    pushd level1 > /dev/null

    expected=$'cpuinfo'
    result=$(gnarly)
    assertEquals "Should find commands in level1" "$expected" "$result"
}

test_gnarly_level2() {
    create_gnarly_file_root
    create_gnarly_file_level1
    create_gnarly_file_level2
    pushd level1/level2 > /dev/null

    expected=$'meminfo'
    result=$(gnarly)
    assertEquals "Should find commands in level2" "$expected" "$result"
}

test_gnarly_level3() {
    create_gnarly_file_root
    create_gnarly_file_level1
    create_gnarly_file_level2
    create_gnarly_file_level3
    pushd level1/level2/level3 > /dev/null

    expected=$'diskinfo\ndistroinfo\nkerninfo\nmeminfo'
    result=$(gnarly)
    assertEquals "Should find commands in level3" "$expected" "$result"
}

test_gnarly_invalid_yaml() {
    gnarly init > /dev/null
    echo "invalid: yaml: content" > .gnarly.yml
    result=$(hello 2>&1)
    assertContains "Should handle invalid YAML" "$result" "Error: bad file"
}

# Debug mode tests
test_gnarly_debug_mode() {
    GNARLY_DEBUG=1 gnarly init > /dev/null
    result=$(GNARLY_DEBUG=1 hello 2>&1)
    assertContains "Should echo debug messages" "$result" "DEBUG"
}

# Load and run the tests
source "$SHUNIT_HOME/shunit2"