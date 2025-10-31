#!/bin/bash
# setup-x11.sh - Setup X11 permissions for Docker containers

set -e

echo "Setting up X11 permissions for Docker containers..."

# Check if X11 is available
if [ -z "$DISPLAY" ]; then
    echo "Warning: DISPLAY environment variable is not set"
    echo "Trying to set DISPLAY to :0"
    export DISPLAY=:0
fi

# Check if X server is running
if ! xset q &>/dev/null; then
    echo "Error: X server is not running or not accessible"
    echo "Please make sure:"
    echo "1. You are running this on a machine with a display"
    echo "2. X server is running"
    echo "3. DISPLAY environment variable is set correctly"
    exit 1
fi

# Set xhost permissions
echo "Adding Docker containers to X11 access control list..."
xhost +local:docker

if [ $? -eq 0 ]; then
    echo "✓ X11 permissions configured successfully"
    echo "✓ Docker containers can now access the display"
else
    echo "✗ Failed to configure X11 permissions"
    exit 1
fi

# Display current xhost settings
echo ""
echo "Current X11 access control:"
xhost

echo ""
echo "X11 setup complete. You can now run GUI applications in Docker containers."