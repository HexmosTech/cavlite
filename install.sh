#!/bin/bash

# cavlite Install Script

set -e

# Parse version argument (e.g., --v0.0.2)
VERSION=""
if [ $# -gt 0 ] && [[ "$1" == --v* ]]; then
    VERSION="${1#--}"  # Remove leading --
fi

if [ -z "$VERSION" ]; then
    echo "🔍 Checking for latest version..."
    VERSION=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/HexmosTech/cavlite/releases/latest | sed 's|.*/tag/||')
    echo "✅ Latest version found: $VERSION"
fi

REPO_URL="https://github.com/HexmosTech/cavlite/releases/download/$VERSION"
INSTALL_PATH="/usr/local/bin/cavlite"
LIB_DIR="/usr/local/lib/cavlite"
CONFIG_DIR="/etc/cavlite"
CONFIG_FILE="$CONFIG_DIR/cavlite.conf"
CLAMAV_CONFIG_DIR="/etc/clamav"
BACKUP_DIR="$HOME/.cavlite/backup/clamav"

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "❌ Please run as root (sudo ./install.sh)"
        exit 1
    fi
}

check_dependencies() {
    echo "🔍 Checking dependencies..."
    local dependencies=("python3" "curl" "clamscan" "lynis")
    local missing=0

    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            echo "❌ Error: $dep is not installed."
            echo "ℹ️  Please install $dep and try again."
            missing=1
        fi
    done

    if [ $missing -eq 1 ]; then
        exit 1
    fi
    echo "✅ Dependencies found."
}

fetch_files() {
    echo "⬇️  Downloading cavlite..."
    
    # Download cavlite
    if ! curl -fsSL "$REPO_URL/cavlite" -o "$INSTALL_PATH"; then
        echo "❌ Error: Failed to download cavlite from GitHub."
        exit 1
    fi
    chmod +x "$INSTALL_PATH"

    # Setup Library Directory and Filter Script
    echo "⚙️  Setting up library files..."
    mkdir -p "$LIB_DIR"
    if ! curl -fsSL "$REPO_URL/filter" -o "$LIB_DIR/filter"; then
        echo "⚠️  Warning: Failed to download filter script."
    fi
    chmod +x "$LIB_DIR/filter"
}

setup_config() {
    # Setup cavlite config
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "⚙️  Setting up default configuration at $CONFIG_FILE"
        mkdir -p "$CONFIG_DIR"
        if ! curl -fsSL "$REPO_URL/cavlite.conf" -o "$CONFIG_FILE"; then
             echo "⚠️  Warning: Failed to download default config."
        fi
    else
        echo "⚠️  Configuration file already exists at $CONFIG_FILE. Skipping overwrite."
    fi

    # Setup ClamAV configs
    echo "⚙️  Configuring ClamAV..."
    mkdir -p "$BACKUP_DIR"
    
    # Backup and replace clamd.conf
    if [ -f "$CLAMAV_CONFIG_DIR/clamd.conf" ]; then
        echo "📦 Backing up clamd.conf to $BACKUP_DIR"
        cp "$CLAMAV_CONFIG_DIR/clamd.conf" "$BACKUP_DIR/clamd.conf.$(date +%F_%T)"
    fi
    if ! curl -fsSL "$REPO_URL/clamd.conf" -o "$CLAMAV_CONFIG_DIR/clamd.conf"; then
         echo "⚠️  Warning: Failed to download clamd.conf."
    fi

    # Backup and replace freshclam.conf
    if [ -f "$CLAMAV_CONFIG_DIR/freshclam.conf" ]; then
        echo "📦 Backing up freshclam.conf to $BACKUP_DIR"
        cp "$CLAMAV_CONFIG_DIR/freshclam.conf" "$BACKUP_DIR/freshclam.conf.$(date +%F_%T)"
    fi
    if ! curl -fsSL "$REPO_URL/freshclam.conf" -o "$CLAMAV_CONFIG_DIR/freshclam.conf"; then
         echo "⚠️  Warning: Failed to download freshclam.conf."
    fi
}

main() {
    echo "🚀 Installing cavlite..."
    check_root
    check_dependencies
    fetch_files
    setup_config
    echo "✅ Installation complete!"
    echo "Run 'sudo cavlite --help' to get started."
}

main