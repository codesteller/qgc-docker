#
# * @ Copyright: @copyright (c) 2025 Gahan AI Private Limited
# * @ Author: Pallab Maji
# * @ Create Time: 2025-10-31 10:44:33
# * @ Modified time: 2025-10-31 16:15:00
# * @ Description: CMake build system for QGroundControl Docker container management
# */

cmake_minimum_required(VERSION 3.16)
project(QGroundControl-Docker VERSION 1.0.0 LANGUAGES NONE)

# Set default build type
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Choose Release or Debug" FORCE)
endif()

# Project configuration
set(DOCKER_IMAGE_NAME "qgc" CACHE STRING "Docker image name")
set(DOCKER_IMAGE_TAG "latest" CACHE STRING "Docker image tag")
set(DOCKER_CONTAINER_NAME "qgc-container" CACHE STRING "Docker container name")

# GPU support option
option(ENABLE_GPU "Enable NVIDIA GPU support" ON)
option(ENABLE_DISPLAY "Enable X11 display forwarding" ON)
option(ENABLE_NETWORK_HOST "Use host networking" ON)
option(ENABLE_SERIAL_DEVICES "Enable serial device access" ON)

# Serial device configuration
set(SERIAL_DEVICE "/dev/ttyUSB0" CACHE STRING "Serial device path")
set(DISPLAY_RESOLUTION "1280x720x24" CACHE STRING "Display resolution for headless mode")

# Include custom CMake modules
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(Docker)

# Find required programs
find_program(DOCKER_EXECUTABLE docker REQUIRED)
find_program(DOCKER_COMPOSE_EXECUTABLE docker-compose)

if(NOT DOCKER_EXECUTABLE)
    message(FATAL_ERROR "Docker executable not found. Please install Docker.")
endif()

# Display configuration summary
message(STATUS "QGroundControl Docker Project Configuration:")
message(STATUS "  Docker Image: ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}")
message(STATUS "  Container Name: ${DOCKER_CONTAINER_NAME}")
message(STATUS "  GPU Support: ${ENABLE_GPU}")
message(STATUS "  Display Forwarding: ${ENABLE_DISPLAY}")
message(STATUS "  Host Network: ${ENABLE_NETWORK_HOST}")
message(STATUS "  Serial Devices: ${ENABLE_SERIAL_DEVICES}")
if(ENABLE_SERIAL_DEVICES)
    message(STATUS "  Serial Device: ${SERIAL_DEVICE}")
endif()

# Create build directory for generated files
file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/docker")

# Generate Docker run script
configure_docker_run_script()

# Docker build target
add_custom_target(docker-build
    COMMAND ${DOCKER_EXECUTABLE} build 
        -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} 
        ${CMAKE_CURRENT_SOURCE_DIR}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Building Docker image ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
    VERBATIM
)

# Docker run target
add_custom_target(docker-run
    COMMAND ${CMAKE_BINARY_DIR}/docker/run-qgc.sh
    DEPENDS docker-build
    COMMENT "Running QGroundControl Docker container"
    VERBATIM
)

# Docker run with GUI target (explicit display forwarding)
add_custom_target(docker-run-gui
    COMMAND ${CMAKE_BINARY_DIR}/docker/run-qgc-gui.sh
    DEPENDS docker-build
    COMMENT "Running QGroundControl with GUI forwarding"
    VERBATIM
)

# Docker run headless target (for VNC access)
add_custom_target(docker-run-headless
    COMMAND ${CMAKE_BINARY_DIR}/docker/run-qgc-headless.sh
    DEPENDS docker-build
    COMMENT "Running QGroundControl in headless mode"
    VERBATIM
)

# Docker stop target
add_custom_target(docker-stop
    COMMAND ${DOCKER_EXECUTABLE} stop ${DOCKER_CONTAINER_NAME} || true
    COMMAND ${DOCKER_EXECUTABLE} rm ${DOCKER_CONTAINER_NAME} || true
    COMMENT "Stopping and removing QGroundControl Docker container"
    VERBATIM
)

# Docker clean target
add_custom_target(docker-clean
    COMMAND ${DOCKER_EXECUTABLE} rmi ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} || true
    DEPENDS docker-stop
    COMMENT "Cleaning Docker image and container"
    VERBATIM
)

# Docker logs target
add_custom_target(docker-logs
    COMMAND ${DOCKER_EXECUTABLE} logs -f ${DOCKER_CONTAINER_NAME}
    COMMENT "Following Docker container logs"
    VERBATIM
)

# Docker shell target for debugging
add_custom_target(docker-shell
    COMMAND ${DOCKER_EXECUTABLE} run -it --rm 
        --entrypoint /bin/bash 
        ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
    DEPENDS docker-build
    COMMENT "Opening shell in Docker container for debugging"
    VERBATIM
)

# Setup X11 permissions target
add_custom_target(setup-x11
    COMMAND xhost +local:docker
    COMMENT "Setting up X11 permissions for Docker"
    VERBATIM
)

# Docker Compose targets (if docker-compose is available)
if(DOCKER_COMPOSE_EXECUTABLE)
    add_custom_target(compose-up
        COMMAND ${DOCKER_COMPOSE_EXECUTABLE} up -d
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Starting services with Docker Compose"
        VERBATIM
    )
    
    add_custom_target(compose-down
        COMMAND ${DOCKER_COMPOSE_EXECUTABLE} down
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Stopping services with Docker Compose"
        VERBATIM
    )
    
    add_custom_target(compose-logs
        COMMAND ${DOCKER_COMPOSE_EXECUTABLE} logs -f
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Following Docker Compose logs"
        VERBATIM
    )
endif()

# Help target to show available commands
add_custom_target(show-help
    COMMAND ${CMAKE_COMMAND} -E echo "Available targets:"
    COMMAND ${CMAKE_COMMAND} -E echo "  docker-build      - Build the Docker image"
    COMMAND ${CMAKE_COMMAND} -E echo "  docker-run        - Run QGroundControl auto-detect display"
    COMMAND ${CMAKE_COMMAND} -E echo "  docker-run-gui    - Run QGroundControl with GUI forwarding"
    COMMAND ${CMAKE_COMMAND} -E echo "  docker-run-headless - Run QGroundControl in headless mode"
    COMMAND ${CMAKE_COMMAND} -E echo "  docker-stop       - Stop and remove container"
    COMMAND ${CMAKE_COMMAND} -E echo "  docker-clean      - Clean Docker image and container"
    COMMAND ${CMAKE_COMMAND} -E echo "  docker-logs       - Follow container logs"
    COMMAND ${CMAKE_COMMAND} -E echo "  docker-shell      - Open shell in container for debugging"
    COMMAND ${CMAKE_COMMAND} -E echo "  setup-x11         - Setup X11 permissions for Docker"
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E echo "Configuration options use -D with cmake:"
    COMMAND ${CMAKE_COMMAND} -E echo "  DOCKER_IMAGE_NAME     - Docker image name default: qgc"
    COMMAND ${CMAKE_COMMAND} -E echo "  DOCKER_IMAGE_TAG      - Docker image tag default: latest"
    COMMAND ${CMAKE_COMMAND} -E echo "  ENABLE_GPU            - Enable GPU support default: ON"
    COMMAND ${CMAKE_COMMAND} -E echo "  ENABLE_DISPLAY        - Enable display forwarding default: ON"
    COMMAND ${CMAKE_COMMAND} -E echo "  SERIAL_DEVICE         - Serial device path default: /dev/ttyUSB0"
    COMMENT "Showing help information"
)

# Make help the default target
add_custom_target(default_target ALL DEPENDS show-help)