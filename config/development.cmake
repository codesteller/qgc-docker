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
set(DOCKER_IMAGE_NAME "qgc" CACHE STRING "Docker image name" FORCE)
set(DOCKER_IMAGE_TAG "dev" CACHE STRING "Docker image tag" FORCE)

# Feature flags
set(ENABLE_GPU ON CACHE BOOL "Enable GPU support" FORCE)
set(ENABLE_DISPLAY ON CACHE BOOL "Enable display forwarding" FORCE)
set(ENABLE_NETWORK_HOST ON CACHE BOOL "Use host networking" FORCE)
set(ENABLE_SERIAL_DEVICES ON CACHE BOOL "Enable serial devices" FORCE)

# Device configuration
set(SERIAL_DEVICE "/dev/ttyUSB0" CACHE STRING "Serial device path" FORCE)

# Development-specific settings
set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Build type" FORCE)
set(DOCKER_CONTAINER_NAME "qgc-dev" CACHE STRING "Container name" FORCE)

# Display settings
set(DISPLAY_RESOLUTION "1920x1080x24" CACHE STRING "Display resolution" FORCE)