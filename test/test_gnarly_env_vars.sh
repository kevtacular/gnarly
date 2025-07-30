#!/bin/bash

source common.sh

# Environment variable tests

test_gnarly_cfg_dir() {
    cat > .gnarly.yml << EOF
commands:
  cfgdir: echo \$GNARLY_CFG_DIR
EOF
    expected=$(realpath ".")
    result=$(cfgdir)
    assertEquals "Should set the \$GNARLY_CFG_DIR environment variable" "$expected" "$result"
}

test_gnarly_cfg_file() {
    cat > .gnarly.yml << EOF
commands:
  cfgfile: echo \$GNARLY_CFG_FILE
EOF
    expected=$(realpath ".")/$GNARLY_FILENAME
    result=$(cfgfile)
    assertEquals "Should set the \$GNARLY_CFG_FILE environment variable" "$expected" "$result"
}

test_gnarly_filename() {
    cat > .gnarrrrrrly.yaml << EOF
commands:
  cfgfile: echo \$GNARLY_CFG_FILE
EOF
    expected=$(realpath ".")/.gnarrrrrrly.yaml
    result=$(GNARLY_FILENAME='.gnarrrrrrly.yaml' cfgfile)
    assertEquals "Should set the \$GNARLY_CFG_FILE environment variable" "$expected" "$result"
}

# Load and run the tests
source "$SHUNIT_HOME/shunit2"