#!/bin/bash

# Find and run all test files that end with _test.sh
for test in test_*.sh; do
    if [ -f "$test" ]; then
        echo "Running test suite: $test"
        echo "------------------------"
        ./$test
        echo -e "\n"
    fi
done