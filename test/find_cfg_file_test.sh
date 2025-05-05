#!/bin/bash

source common.sh

testFindCfgFile_root() {
    _gnarly_find_cfg_file
    assertEquals "$PWD/.gnarly/bash.yml" "$gnarly_cfg_file"
}

testFindCfgFile_level1() {
    pushd level1 > /dev/null
    _gnarly_find_cfg_file
    assertEquals "$PWD/.gnarly/bash.yml" "$gnarly_cfg_file"
    popd > /dev/null
}

testFindCfgFile_level2() {
    pushd level1/level2 > /dev/null
    _gnarly_find_cfg_file
    assertEquals "$PWD/.gnarly/bash.yml" "$gnarly_cfg_file"
    popd > /dev/null
}

testFindCfgFile_level3() {
    pushd level1/level2/level3 > /dev/null
    _gnarly_find_cfg_file
    assertEquals "$PWD/.gnarly/bash.yml" "$gnarly_cfg_file"
    popd > /dev/null
}

source $SHUNIT_HOME/shunit2
