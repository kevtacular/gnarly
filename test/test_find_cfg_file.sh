#!/bin/bash

source common.sh

test_find_cfg_file_root() {
    touch ".gnarly.yml"
    _gnarly_find_cfg_file
    assertEquals "$PWD/.gnarly.yml" "$gnarly_cfg_file"
}

test_find_cfg_file_level1() {
    gfile=$(realpath ".gnarly.yml")
    touch "$gfile"
    mkdir level1
    pushd level1 > /dev/null

    _gnarly_find_cfg_file
    assertEquals "$gfile" "$gnarly_cfg_file"

    popd > /dev/null
    rmdir level1
}

test_find_cfg_file_level2() {
    gfile=$(realpath ".gnarly.yml")
    touch "$gfile"
    mkdir -p level1/level2
    pushd level1/level2 > /dev/null

    _gnarly_find_cfg_file
    assertEquals "$gfile" "$gnarly_cfg_file"

    popd > /dev/null
    rmdir -p level1/level2
}

test_find_cfg_file_level3() {
    gfile=$(realpath ".gnarly.yml")
    touch "$gfile"
    mkdir -p level1/level2/level3
    pushd level1/level2/level3 > /dev/null

    _gnarly_find_cfg_file
    assertEquals "$gfile" "$gnarly_cfg_file"

    popd > /dev/null
    rmdir -p level1/level2/level3
}

source $SHUNIT_HOME/shunit2
