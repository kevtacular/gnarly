#!/bin/bash

set -e

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$(dirname "$script_dir")" || {
    echo "Error: Could not change to project root directory"
    exit 1
}

# Verify we're in the right place
if [ ! -f "VERSION" ]; then
    echo "Error: VERSION file not found. Must run from project root."
    exit 1
fi

# Remind user to run tests first
read -p "Have you run all tests and confirmed they pass? (y/n): " yn
case $yn in
    [Yy]* ) ;;
    * ) echo "Aborting release. Please run tests first."; exit 1;;
esac

# Get the version from the user
current_version=$(cat VERSION)
read -p "Enter the new version number (current is $current_version): " version

if [ -z "$version" ]; then
    echo "No version number entered. Aborting."
    exit 1
fi

# Update the VERSION file
echo "$version" > VERSION

# Commit the version change
git add VERSION
git commit -m "chore(release): v$version"

# Create a git tag
git tag -a "v$version" -m "Release v$version"

# Push the commit and tag
git push
git push --tags

echo "Version $version has been tagged and pushed."
echo "Now, go to GitHub and create a new release from the v$version tag."
