#!/bin/bash

source common.sh

test_gnarly() {
    expected=$'hello\nkerninfo\nsysinfo'
    result=$(gnarly)
    assertEquals "$expected" "$result"
}

test_gnarly_level1() {
    pushd level1 > /dev/null
    expected=$'cpuinfo'
    result=$(gnarly)
    assertEquals "$expected" "$result"
    popd > /dev/null
}

test_gnarly_level2() {
    pushd level1/level2 > /dev/null
    expected=$'meminfo'
    result=$(gnarly)
    assertEquals "$expected" "$result"
    popd > /dev/null
}

test_gnarly_level3() {
    pushd level1/level2/level3 > /dev/null
    expected=$'diskinfo\ndistroinfo\nkerninfo\nmeminfo'
    result=$(gnarly)
    assertEquals "$expected" "$result"
    popd > /dev/null
}

test_gnarly_show_simple() {
    result=$(gnarly show hello)
    assertEquals 'echo "Hello, World!"' "$result"
}

test_gnarly_show_script() {
    expected=$'script: |\n  echo "=== System Information ==="\n  uname -a\n  echo -e "\\n=== CPU Info ==="\n  lscpu | grep -E "^(Model name|Architecture|CPU\\(s\\))"\n  echo -e "\\n=== Memory Info ==="\n  free -h\n  echo -e "\\n=== Disk Usage ==="\n  df -h\n  echo -e "\\n=== Distribution Info ==="\n  cat /etc/os-release | grep -E "^(NAME|VERSION)="'
    result=$(gnarly show sysinfo)
    assertEquals "$expected" "$result"
}
source $SHUNIT_HOME/shunit2