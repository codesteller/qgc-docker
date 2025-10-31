#
# * @ Copyright: @copyright (c) 2025 Gahan AI Private Limited
# * @ Author: Pallab Maji
# * @ Create Time: 2025-10-31 10:44:33
# * @ Modified time: 2025-10-31 16:15:00
# * @ Description: Headless configuration preset for QGroundControl Docker
# */

# Headless Configuration for QGroundControl Docker
# This preset is for server deployments without display

# Image settings
set(DOCKER_IMAGE_NAME "qgc" CACHE STRING "Docker image name" FORCE)
set(DOCKER_IMAGE_TAG "headless" CACHE STRING "Docker image tag" FORCE)

# Feature flags (headless settings)
set(ENABLE_GPU OFF CACHE BOOL "Enable GPU support" FORCE)
set(ENABLE_DISPLAY OFF CACHE BOOL "Enable display forwarding" FORCE)
set(ENABLE_NETWORK_HOST ON CACHE BOOL "Use host networking" FORCE)
set(ENABLE_SERIAL_DEVICES ON CACHE BOOL "Enable serial devices" FORCE)

# Device configuration
set(SERIAL_DEVICE "/dev/ttyUSB0" CACHE STRING "Serial device path" FORCE)

# Headless-specific settings
set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Build type" FORCE)
set(DOCKER_CONTAINER_NAME "qgc-headless" CACHE STRING "Container name" FORCE)

# Display settings (for VNC)
set(DISPLAY_RESOLUTION "1280x720x24" CACHE STRING "Display resolution" FORCE)