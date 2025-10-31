#
# * @ Copyright: @copyright (c) 2025 Gahan AI Private Limited
# * @ Author: Pallab Maji
# * @ Create Time: 2025-10-31 10:44:33
# * @ Modified time: 2025-10-31 16:15:00
# * @ Description: Production configuration preset for QGroundControl Docker
# */

# Production Configuration for QGroundControl Docker
# This preset is optimized for production deployment

# Image settings
DOCKER_IMAGE_NAME=qgc
DOCKER_IMAGE_TAG=latest

# Feature flags (conservative settings for production)
ENABLE_GPU=OFF
ENABLE_DISPLAY=ON
ENABLE_NETWORK_HOST=ON
ENABLE_SERIAL_DEVICES=ON

# Device configuration
SERIAL_DEVICE=/dev/ttyUSB0

# Production-specific settings
CMAKE_BUILD_TYPE=Release
DOCKER_CONTAINER_NAME=qgc-production

# Display settings
DISPLAY_RESOLUTION=1280x720x24