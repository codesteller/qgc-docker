# Development Configuration for QGroundControl Docker
# This preset enables all features for development

# Image settings
DOCKER_IMAGE_NAME=qgc
DOCKER_IMAGE_TAG=dev

# Feature flags
ENABLE_GPU=ON
ENABLE_DISPLAY=ON
ENABLE_NETWORK_HOST=ON
ENABLE_SERIAL_DEVICES=ON

# Device configuration
SERIAL_DEVICE=/dev/ttyUSB0

# Development-specific settings
CMAKE_BUILD_TYPE=Debug
DOCKER_CONTAINER_NAME=qgc-dev

# Display settings
DISPLAY_RESOLUTION=1920x1080x24