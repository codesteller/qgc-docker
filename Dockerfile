#
# * @ Copyright: @copyright (c) 2025 Gahan AI Private Limited
# * @ Author: Pallab Maji
# * @ Create Time: 2025-10-31 10:44:33
# * @ Modified time: 2025-10-31 16:15:00
# * @ Description: Docker image to run QGroundControl AppImage on Ubuntu 22.04
# */


# FROM ubuntu:22.04
# FROM nvcr.io/nvidia/cuda:12.8.1-cudnn-devel-ubuntu22.04
FROM ubuntu:22.04

ARG QGC_DOWNLOAD_LINK=https://d176tv9ibo4jno.cloudfront.net/latest/QGroundControl-x86_64.AppImage

# Base deps + GL/EGL runtime
RUN apt-get update && apt-get install -y \
  ca-certificates wget x11-apps \
  libegl1 libgles2 libglvnd0 libgl1-mesa-dri mesa-vulkan-drivers \
  libopengl0 libglu1-mesa libgl1-mesa-glx \
  libglib2.0-0 libpulse0 libx11-xcb1 libnss3 \
  libxcomposite1 libxcursor1 libxdamage1 libxi6 libxtst6 libxrandr2 \
  libasound2 libxkbcommon-x11-0 && rm -rf /var/lib/apt/lists/*

# Create non-root user (matches default 1000:1000; override via build args if needed)
ARG USER=qgcuser
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} ${USER} && useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USER}

# Fetch AppImage and extract (avoid FUSE) + install launcher
WORKDIR /opt/qgc
RUN wget "${QGC_DOWNLOAD_LINK}" -O QGC.AppImage && \
    chmod +x QGC.AppImage && ./QGC.AppImage --appimage-extract && \
    ln -s /opt/qgc/squashfs-root/AppRun /usr/local/bin/qgc && \
    chown -R ${USER}:${USER} /opt/qgc

# Persist settings location (owned by non-root)
RUN mkdir -p /home/${USER}/.config/QGroundControl.org && chown -R ${USER}:${USER} /home/${USER}/.config
ENV QT_X11_NO_MITSHM=1

USER ${USER}
CMD ["qgc"]



