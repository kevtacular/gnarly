#!/bin/bash

# Installer for gnarly
#
# This script installs gnarly to a hidden directory in the user's home
# directory and adds a line to the user's .bashrc to source the gnarly
# script.

set -e

# Configuration
GITHUB_REPO="kevtacular/gnarly"
INSTALL_DIR="$HOME/.gnarly"

# Find the latest version from GitHub releases
get_latest_release() {
    curl --silent "https://api.github.com/repos/$GITHUB_REPO/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                                     # Get tag line
    sed -E 's/.*"v*([^"]+)".*/\1/'                                         # Pluck JSON value
}

# Install gnarly
install_gnarly() {
    local version
    version=$(get_latest_release)
    if [ -z "$version" ]; then
        echo "Error: Could not find the latest release of gnarly."
        exit 1
    fi

    echo "Installing gnarly version $version..."

    # Create the installation directory
    mkdir -p "$INSTALL_DIR"

    # Download the script and VERSION file
    curl -fsSL "https://raw.githubusercontent.com/$GITHUB_REPO/v$version/gnarly.sh" -o "$INSTALL_DIR/gnarly.sh"
    curl -fsSL "https://raw.githubusercontent.com/$GITHUB_REPO/v$version/VERSION" -o "$INSTALL_DIR/VERSION"

    # Add sourcing to .bashrc if it's not already there
    local source_line="source \"$INSTALL_DIR/gnarly.sh\""
    if ! grep -q "$source_line" "$HOME/.bashrc"; then
        echo "Adding gnarly to your .bashrc..."
        echo -e "\n# Gnarly configuration\n$source_line" >> "$HOME/.bashrc"
    fi

    echo "Gnarly installed successfully!"
    echo
    echo "Please open a new terminal or run the following command to start using gnarly:"
    echo "  source ~/.bashrc"
}

install_gnarly
