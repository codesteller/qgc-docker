#!/bin/bash
#
# * @ Copyright: @copyright (c) 2025 Gahan AI Private Limited
# * @ Author: Pallab Maji
# * @ Create Time: 2025-10-31 10:44:33
# * @ Modified time: 2025-10-31 16:15:00
# * @ Description: Docker startup script for QGroundControl with GPU support detection
# */

xhost +local:docker

# If GPU is available, run with nvidia runtime
if command -v nvidia-smi &> /dev/null; then
    RUNTIME_ARGS="--gpus all"
else
    RUNTIME_ARGS=""
fi

docker run -it --rm \
    --env="QT_X11_NO_MITSHM=1" \
    --env="DISPLAY=$DISPLAY" \
    --net=host \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /dev:/dev \
    -v ${PWD}/data:/data \
    qgc:latest 



