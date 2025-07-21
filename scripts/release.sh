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

# 1. Get the version from the user
current_version=$(cat VERSION)
read -p "Enter the new version number (current is $current_version): " version

if [ -z "$version" ]; then
    echo "No version number entered. Aborting."
    exit 1
fi

# 2. Update the VERSION file
echo "$version" > VERSION

# 3. Commit the version change
git add VERSION
git commit -m "chore(release): v$version"

# 4. Create a git tag
git tag -a "v$version" -m "Release v$version"

# 5. Push the commit and tag
git push
git push --tags

echo "Version $version has been tagged and pushed."
echo "Now, go to GitHub and create a new release from the v$version tag."
