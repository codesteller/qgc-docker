# Headless Configuration for QGroundControl Docker
# This preset is for server deployments without display

# Image settings
DOCKER_IMAGE_NAME=qgc
DOCKER_IMAGE_TAG=headless

# Feature flags (headless settings)
ENABLE_GPU=OFF
ENABLE_DISPLAY=OFF
ENABLE_NETWORK_HOST=ON
ENABLE_SERIAL_DEVICES=ON

# Device configuration
SERIAL_DEVICE=/dev/ttyUSB0

# Headless-specific settings
CMAKE_BUILD_TYPE=Release
DOCKER_CONTAINER_NAME=qgc-headless

# Display settings (for VNC)
DISPLAY_RESOLUTION=1280x720x24