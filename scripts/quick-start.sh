#!/bin/bash
#
# * @ Copyright: @copyright (c) 2025 Gahan AI Private Limited
# * @ Author: Pallab Maji
# * @ Create Time: 2025-10-31 10:44:33
# * @ Modified time: 2025-10-31 16:15:00
# * @ Description: Quick start script for QGroundControl Docker
# */

# quick-start.sh - Quick start script for QGroundControl Docker

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════╗"
echo "║        QGroundControl Docker Quick Start     ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if we're in the right directory
if [ ! -f "CMakeLists.txt" ] || [ ! -f "Dockerfile" ]; then
    echo -e "${RED}Error: Please run this script from the QGroundControl Docker project directory${NC}"
    exit 1
fi

# Function to ask user for confirmation
ask_confirmation() {
    while true; do
        read -p "$1 (y/n): " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

echo "This script will help you get QGroundControl running in Docker quickly."
echo ""

# Step 1: System check
echo -e "${YELLOW}Step 1: Checking system requirements...${NC}"
if [ -f "scripts/check-system.sh" ]; then
    ./scripts/check-system.sh
    echo ""
    if ! ask_confirmation "Did the system check pass? Continue with setup?"; then
        echo "Please fix the issues and run this script again."
        exit 1
    fi
else
    echo "System check script not found. Proceeding anyway..."
fi

# Step 2: Setup X11 permissions
echo ""
echo -e "${YELLOW}Step 2: Setting up X11 permissions...${NC}"
if [ -n "$DISPLAY" ]; then
    echo "Setting up X11 permissions for Docker..."
    xhost +local:docker || echo "Warning: Could not set xhost permissions"
    echo -e "${GREEN}✓ X11 setup completed${NC}"
else
    echo -e "${YELLOW}⚠ No DISPLAY set. GUI may not work.${NC}"
fi

# Step 3: Create build directory and configure
echo ""
echo -e "${YELLOW}Step 3: Configuring CMake build...${NC}"
if [ ! -d "build" ]; then
    mkdir -p build
fi

cd build

# Ask for configuration type
echo "Choose configuration type:"
echo "1) Development (GPU enabled, all features)"
echo "2) Production (stable, conservative settings)"  
echo "3) Headless (for server deployment)"
echo "4) Custom"

while true; do
    read -p "Enter choice (1-4): " choice
    case $choice in
        1)
            echo "Using development configuration..."
            cmake .. -C ../config/development.cmake
            break
            ;;
        2)
            echo "Using production configuration..."
            cmake .. -C ../config/production.cmake
            break
            ;;
        3)
            echo "Using headless configuration..."
            cmake .. -C ../config/headless.cmake
            break
            ;;
        4)
            echo "Using default configuration..."
            cmake ..
            break
            ;;
        *)
            echo "Invalid choice. Please enter 1, 2, 3, or 4."
            ;;
    esac
done

echo -e "${GREEN}✓ CMake configuration completed${NC}"

# Step 4: Build Docker image
echo ""
echo -e "${YELLOW}Step 4: Building Docker image...${NC}"
if ask_confirmation "Build the Docker image now? This may take a few minutes"; then
    make docker-build
    echo -e "${GREEN}✓ Docker image built successfully${NC}"
else
    echo "Skipping Docker build. You can build later with: make docker-build"
fi

# Step 5: Run QGroundControl
echo ""
echo -e "${YELLOW}Step 5: Running QGroundControl...${NC}"
if ask_confirmation "Run QGroundControl now?"; then
    echo "Starting QGroundControl..."
    make docker-run
else
    echo "Skipping run. You can start QGroundControl later with: make docker-run"
fi

echo ""
echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════╗"
echo "║              Setup Complete!                 ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "${NC}"

echo "Available commands:"
echo "  make docker-build      - Build the Docker image"
echo "  make docker-run        - Run QGroundControl (auto-detect)"
echo "  make docker-run-gui    - Run with explicit GUI forwarding"
echo "  make docker-run-headless - Run in headless mode (VNC)"
echo "  make docker-stop       - Stop the container"
echo "  make docker-logs       - View container logs"
echo "  make help              - Show all available commands"
echo ""
echo "For more information, see the README.md file."