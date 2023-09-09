#!/bin/bash
# Project: UseFul Apps
# Author: CompilerByte
# Date: 2023-09-09
# Version: 1.0.0
# Description: Install all the apps in the system using this script
# Usage: ./install.sh
# Note: Run this script as root

# Define variables
INSTALL_DIR="/opt"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # Directory where install.sh is located
APP_DIR="$INSTALL_DIR/apps"
EXECUTABLE_DIR="/usr/local/bin"
ICON_DIR="/usr/share/icons"
DESKTOP_DIR="/usr/share/applications"

# Function to display an error message and exit
function error_exit {
    echo "Error: $1" >&2
    exit 1
}

# Check if the script is being run as root
if [ "$EUID" -ne 0 ]; then
    error_exit "This script must be run as root. Please use sudo."
fi

# Confirm installation directory
echo "This script will install apps from $SCRIPT_DIR/apps to $APP_DIR."
read -p "Continue? (y/n): " choice
if [ "$choice" != "y" ] && [ "$choice" != "Y" ]; then
    echo "Installation aborted."
    exit 0
fi

# Create the installation directory if it doesn't exist
mkdir -p "$APP_DIR" || error_exit "Failed to create installation directory."

# Copy scripts from ./apps/ to /opt/apps/
cp -r "$SCRIPT_DIR/apps/"* "$APP_DIR" || error_exit "Failed to copy scripts to the installation directory."

# Create symbolic links for all apps in /usr/local/bin/ (remove ".sh" extension)
for script in "$APP_DIR"/*; do
    if [ -x "$script" ]; then
        app_name="$(basename "$script")"
        app_name_without_extension="${app_name%.sh}" # Remove ".sh" extension
        ln -s "$script" "$EXECUTABLE_DIR/$app_name_without_extension" || error_exit "Failed to create a symbolic link for $app_name."
    fi
done

# Copy icons from ./icons/ to /usr/share/icons/
cp -r "$SCRIPT_DIR/icons/"* "$ICON_DIR" || error_exit "Failed to copy icons to the system icons directory."

# Create .desktop files for each app
for script in "$APP_DIR"/*; do
    if [ -x "$script" ]; then
        app_name="$(basename "$script" | cut -d'.' -f1)"
        desktop_file="$DESKTOP_DIR/$app_name.desktop"
        cat > "$desktop_file" <<EOF
[Desktop Entry]
Name=$app_name
Exec=$app_name_without_extension
Icon=$app_name
Terminal=false
Type=Application
Categories=Utility;
EOF
    fi
done

echo "Apps have been successfully installed to $APP_DIR."
echo "You can now run them from the command line or find them in your application launcher."

exit 0

