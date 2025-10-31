#
# * @ Copyright: @copyright (c) 2025 Gahan AI Private Limited
# * @ Author: Pallab Maji
# * @ Create Time: 2025-10-31 10:44:33
# * @ Modified time: 2025-10-31 16:15:00
# * @ Description: Development configuration preset for QGroundControl Docker
# */

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