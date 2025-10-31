#!/bin/bash
# check-system.sh - Check system requirements for QGroundControl Docker

set -e

echo "QGroundControl Docker System Check"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check functions
check_ok() {
    echo -e "${GREEN}✓${NC} $1"
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
}

# Check Docker installation
echo ""
echo "Checking Docker installation..."
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    check_ok "Docker is installed: $DOCKER_VERSION"
    
    # Check if Docker daemon is running
    if docker info &> /dev/null; then
        check_ok "Docker daemon is running"
    else
        check_fail "Docker daemon is not running. Please start Docker service."
    fi
else
    check_fail "Docker is not installed. Please install Docker first."
fi

# Check Docker Compose
echo ""
echo "Checking Docker Compose..."
if command -v docker-compose &> /dev/null; then
    COMPOSE_VERSION=$(docker-compose --version)
    check_ok "Docker Compose is installed: $COMPOSE_VERSION"
elif docker compose version &> /dev/null; then
    COMPOSE_VERSION=$(docker compose version)
    check_ok "Docker Compose (plugin) is available: $COMPOSE_VERSION"
else
    check_warn "Docker Compose not found. Some features may not be available."
fi

# Check X11/Display
echo ""
echo "Checking display system..."
if [ -n "$DISPLAY" ]; then
    check_ok "DISPLAY is set: $DISPLAY"
    
    if command -v xset &> /dev/null && xset q &> /dev/null; then
        check_ok "X11 server is accessible"
    else
        check_warn "X11 server may not be accessible"
    fi
else
    check_warn "DISPLAY not set. GUI forwarding may not work."
fi

# Check Wayland
if [ -n "$WAYLAND_DISPLAY" ]; then
    check_ok "Wayland display detected: $WAYLAND_DISPLAY"
fi

# Check GPU support
echo ""
echo "Checking GPU support..."
if command -v nvidia-smi &> /dev/null; then
    if nvidia-smi &> /dev/null; then
        GPU_INFO=$(nvidia-smi --query-gpu=name --format=csv,noheader,nounits | head -1)
        check_ok "NVIDIA GPU detected: $GPU_INFO"
        
        # Check Docker GPU support
        if docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi &> /dev/null; then
            check_ok "Docker GPU support is working"
        else
            check_warn "Docker GPU support not working. Install nvidia-docker2."
        fi
    else
        check_warn "nvidia-smi found but not working"
    fi
else
    check_warn "No NVIDIA GPU detected (nvidia-smi not found)"
fi

# Check serial devices
echo ""
echo "Checking serial devices..."
SERIAL_DEVICES=()
for device in /dev/ttyUSB* /dev/ttyACM*; do
    if [ -e "$device" ]; then
        SERIAL_DEVICES+=("$device")
    fi
done

if [ ${#SERIAL_DEVICES[@]} -gt 0 ]; then
    check_ok "Serial devices found: ${SERIAL_DEVICES[*]}"
    
    # Check permissions
    for device in "${SERIAL_DEVICES[@]}"; do
        if [ -r "$device" ] && [ -w "$device" ]; then
            check_ok "Can access $device"
        else
            check_warn "No read/write access to $device. You may need to add user to dialout group."
        fi
    done
else
    check_warn "No serial devices found (/dev/ttyUSB*, /dev/ttyACM*)"
fi

# Check CMake
echo ""
echo "Checking build tools..."
if command -v cmake &> /dev/null; then
    CMAKE_VERSION=$(cmake --version | head -1)
    check_ok "CMake is installed: $CMAKE_VERSION"
else
    check_fail "CMake not found. Please install CMake to use build system."
fi

# System info
echo ""
echo "System Information:"
echo "==================="
echo "OS: $(uname -s)"
echo "Kernel: $(uname -r)"
echo "Architecture: $(uname -m)"
echo "User: $(whoami)"
echo "Groups: $(groups)"

# WSL detection
if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
    echo ""
    check_warn "WSL detected. GUI forwarding may require additional setup."
    echo "Consider using WSLg or VcXsrv for X11 forwarding."
fi

echo ""
echo "System check complete!"
echo ""
echo "Recommendations:"
echo "- If serial access fails, run: sudo usermod -a -G dialout \$USER"
echo "- For GPU support, install nvidia-docker2"
echo "- For X11 issues, run: xhost +local:docker"