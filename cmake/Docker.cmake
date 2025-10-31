#
# * @ Copyright: @copyright (c) 2025 Gahan AI Private Limited
# * @ Author: Pallab Maji
# * @ Create Time: 2025-10-31 10:44:33
# * @ Modified time: 2025-10-31 16:15:00
# * @ Description: Docker utilities and functions for QGroundControl project
# */

# Docker.cmake - Docker utilities for QGroundControl project

# Function to detect if we're running under WSL
function(detect_wsl)
    if(EXISTS "/proc/version")
        file(READ "/proc/version" PROC_VERSION)
        if(PROC_VERSION MATCHES "Microsoft|WSL")
            set(IS_WSL TRUE PARENT_SCOPE)
        else()
            set(IS_WSL FALSE PARENT_SCOPE)
        endif()
    else()
        set(IS_WSL FALSE PARENT_SCOPE)
    endif()
endfunction()

# Function to detect display server
function(detect_display_server)
    # Check if WAYLAND_DISPLAY is set
    if(DEFINED ENV{WAYLAND_DISPLAY} AND NOT "$ENV{WAYLAND_DISPLAY}" STREQUAL "")
        set(DISPLAY_SERVER "wayland" PARENT_SCOPE)
    # Check if DISPLAY is set (X11)
    elseif(DEFINED ENV{DISPLAY} AND NOT "$ENV{DISPLAY}" STREQUAL "")
        set(DISPLAY_SERVER "x11" PARENT_SCOPE)
    else()
        set(DISPLAY_SERVER "none" PARENT_SCOPE)
    endif()
endfunction()

# Function to check if GPU support is available
function(check_gpu_support)
    find_program(NVIDIA_SMI_EXECUTABLE nvidia-smi)
    if(NVIDIA_SMI_EXECUTABLE)
        execute_process(
            COMMAND ${NVIDIA_SMI_EXECUTABLE} -L
            RESULT_VARIABLE GPU_CHECK_RESULT
            OUTPUT_QUIET
            ERROR_QUIET
        )
        if(GPU_CHECK_RESULT EQUAL 0)
            set(HAS_NVIDIA_GPU TRUE PARENT_SCOPE)
        else()
            set(HAS_NVIDIA_GPU FALSE PARENT_SCOPE)
        endif()
    else()
        set(HAS_NVIDIA_GPU FALSE PARENT_SCOPE)
    endif()
endfunction()

# Function to build Docker run arguments
function(build_docker_run_args OUTPUT_VAR)
    set(DOCKER_ARGS "")
    
    # Basic container settings
    list(APPEND DOCKER_ARGS "-it" "--rm")
    list(APPEND DOCKER_ARGS "--name" "${DOCKER_CONTAINER_NAME}")
    
    # GPU support
    if(ENABLE_GPU)
        check_gpu_support()
        if(HAS_NVIDIA_GPU)
            list(APPEND DOCKER_ARGS "--gpus" "all")
            list(APPEND DOCKER_ARGS "--env" "QT_X11_NO_MITSHM=1")
            message(STATUS "GPU support enabled (NVIDIA GPU detected)")
        else()
            message(STATUS "GPU support requested but no NVIDIA GPU detected")
        endif()
    endif()
    
    # Network configuration
    if(ENABLE_NETWORK_HOST)
        list(APPEND DOCKER_ARGS "--net=host")
    endif()
    
    # Display forwarding
    if(ENABLE_DISPLAY)
        detect_display_server()
        detect_wsl()
        
        if(DISPLAY_SERVER STREQUAL "x11")
            list(APPEND DOCKER_ARGS "--env" "DISPLAY=$DISPLAY")
            list(APPEND DOCKER_ARGS "-v" "/tmp/.X11-unix:/tmp/.X11-unix")
            if(NOT IS_WSL)
                list(APPEND DOCKER_ARGS "--env" "XAUTHORITY=$XAUTHORITY")
                list(APPEND DOCKER_ARGS "-v" "$XAUTHORITY:$XAUTHORITY")
            endif()
        elseif(DISPLAY_SERVER STREQUAL "wayland")
            list(APPEND DOCKER_ARGS "--env" "WAYLAND_DISPLAY=$WAYLAND_DISPLAY")
            list(APPEND DOCKER_ARGS "--env" "XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR")
            list(APPEND DOCKER_ARGS "-v" "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY")
        endif()
    endif()
    
    # Serial device access
    if(ENABLE_SERIAL_DEVICES)
        if(EXISTS "${SERIAL_DEVICE}")
            list(APPEND DOCKER_ARGS "--device=${SERIAL_DEVICE}:${SERIAL_DEVICE}")
        else()
            message(WARNING "Serial device ${SERIAL_DEVICE} not found")
        endif()
        
        # Add common serial devices that might be available
        foreach(DEVICE IN ITEMS "/dev/ttyUSB0" "/dev/ttyUSB1" "/dev/ttyACM0" "/dev/ttyACM1")
            if(EXISTS "${DEVICE}" AND NOT "${DEVICE}" STREQUAL "${SERIAL_DEVICE}")
                list(APPEND DOCKER_ARGS "--device=${DEVICE}:${DEVICE}")
            endif()
        endforeach()
    endif()
    
    # Persistent data volumes
    list(APPEND DOCKER_ARGS "-v" "${CMAKE_CURRENT_SOURCE_DIR}/data/QGCSettings:/root/.config/QGroundControl.org")
    list(APPEND DOCKER_ARGS "-v" "${CMAKE_CURRENT_SOURCE_DIR}/data/QGCData:/root/Documents/QGroundControl")
    
    # Audio support (optional)
    if(EXISTS "/dev/snd")
        list(APPEND DOCKER_ARGS "--device=/dev/snd:/dev/snd")
    endif()
    
    set(${OUTPUT_VAR} "${DOCKER_ARGS}" PARENT_SCOPE)
endfunction()

# Function to generate Docker run scripts
function(configure_docker_run_script)
    # Create data directories
    file(MAKE_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/data/QGCSettings")
    file(MAKE_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/data/QGCData")
    
    # Build Docker arguments
    build_docker_run_args(DOCKER_RUN_ARGS)
    
    # Convert list to string for script generation
    string(REPLACE ";" " " DOCKER_RUN_ARGS_STR "${DOCKER_RUN_ARGS}")
    
    # Generate main run script
    set(RUN_SCRIPT_CONTENT "#!/bin/bash
set -e

# QGroundControl Docker Run Script
# Generated by CMake

echo \"Starting QGroundControl Docker container...\"

# Setup X11 permissions if needed
if [ \"$DISPLAY\" != \"\" ]; then
    echo \"Setting up X11 permissions...\"
    xhost +local:docker 2>/dev/null || echo \"Warning: Could not set xhost permissions\"
fi

# Run the container
docker run ${DOCKER_RUN_ARGS_STR} ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
")
    
    file(WRITE "${CMAKE_BINARY_DIR}/docker/run-qgc.sh" "${RUN_SCRIPT_CONTENT}")
    execute_process(COMMAND chmod +x "${CMAKE_BINARY_DIR}/docker/run-qgc.sh")
    
    # Generate GUI-specific run script
    set(GUI_SCRIPT_CONTENT "#!/bin/bash
set -e

# QGroundControl Docker GUI Run Script
# Generated by CMake

echo \"Starting QGroundControl with GUI forwarding...\"

# Force X11 setup
if [ \"$DISPLAY\" = \"\" ]; then
    export DISPLAY=:0
    echo \"Warning: DISPLAY not set, using :0\"
fi

echo \"Setting up X11 permissions...\"
xhost +local:docker

# Run with explicit GUI settings
docker run -it --rm \\
    --name ${DOCKER_CONTAINER_NAME} \\
    --env=\"DISPLAY=$DISPLAY\" \\
    --env=\"QT_X11_NO_MITSHM=1\" \\
    --net=host \\
    -v /tmp/.X11-unix:/tmp/.X11-unix")
    
    if(ENABLE_GPU)
        check_gpu_support()
        if(HAS_NVIDIA_GPU)
            string(APPEND GUI_SCRIPT_CONTENT " \\
    --gpus all")
        endif()
    endif()
    
    if(ENABLE_SERIAL_DEVICES AND EXISTS "${SERIAL_DEVICE}")
        string(APPEND GUI_SCRIPT_CONTENT " \\
    --device=${SERIAL_DEVICE}:${SERIAL_DEVICE}")
    endif()
    
    string(APPEND GUI_SCRIPT_CONTENT " \\
    -v \"${CMAKE_CURRENT_SOURCE_DIR}/data/QGCSettings:/home/qgcuser/.config/QGroundControl.org\" \\
    -v \"${CMAKE_CURRENT_SOURCE_DIR}/data/QGCData:/home/qgcuser/Documents/QGroundControl\" \\
    ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
")
    
    file(WRITE "${CMAKE_BINARY_DIR}/docker/run-qgc-gui.sh" "${GUI_SCRIPT_CONTENT}")
    execute_process(COMMAND chmod +x "${CMAKE_BINARY_DIR}/docker/run-qgc-gui.sh")
    
    # Generate headless run script
    set(HEADLESS_SCRIPT_CONTENT "#!/bin/bash
set -e

# QGroundControl Docker Headless Run Script
# Generated by CMake

echo \"Starting QGroundControl in headless mode...\"
echo \"You can connect via VNC on port 5900\"

docker run -it --rm \\
    --name ${DOCKER_CONTAINER_NAME}-headless \\
    --net=host \\")
    
    if(ENABLE_SERIAL_DEVICES)
        string(APPEND HEADLESS_SCRIPT_CONTENT "    --device=${SERIAL_DEVICE}:${SERIAL_DEVICE} \\
")
    endif()
    
    string(APPEND HEADLESS_SCRIPT_CONTENT "    -v \"${CMAKE_CURRENT_SOURCE_DIR}/data/QGCSettings:/root/.config/QGroundControl.org\" \\
    -v \"${CMAKE_CURRENT_SOURCE_DIR}/data/QGCData:/root/Documents/QGroundControl\" \\
    -p 5900:5900 \\
    --entrypoint /bin/bash \\
    ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} \\
    -c \"apt update && apt install -y x11vnc xvfb && xvfb-run -s '-screen 0 ${DISPLAY_RESOLUTION}' x11vnc -forever -usepw -create\"
")
    
    file(WRITE "${CMAKE_BINARY_DIR}/docker/run-qgc-headless.sh" "${HEADLESS_SCRIPT_CONTENT}")
    execute_process(COMMAND chmod +x "${CMAKE_BINARY_DIR}/docker/run-qgc-headless.sh")
    
    message(STATUS "Generated Docker run scripts in ${CMAKE_BINARY_DIR}/docker/")
endfunction()

# Function to create development environment
function(setup_development_environment)
    # Create development directories
    file(MAKE_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/logs")
    file(MAKE_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/config")
    file(MAKE_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/scripts")
    
    # Create development configuration
    set(DEV_CONFIG "# Development Configuration
DOCKER_IMAGE_NAME=${DOCKER_IMAGE_NAME}
DOCKER_IMAGE_TAG=dev
ENABLE_GPU=${ENABLE_GPU}
SERIAL_DEVICE=${SERIAL_DEVICE}
")
    file(WRITE "${CMAKE_CURRENT_SOURCE_DIR}/config/development.env" "${DEV_CONFIG}")
endfunction()