# FROM ubuntu:22.04
# FROM nvcr.io/nvidia/cuda:12.8.1-cudnn-devel-ubuntu22.04

# # Dependencies for QGroundControl
# RUN apt-get update && apt-get install -y \
#     libgl1-mesa-glx \
#     libglib2.0-0 \
#     libpulse0 \
#     libx11-xcb1 \
#     libnss3 \
#     libxcomposite1 \
#     libxcursor1 \
#     libxdamage1 \
#     libxi6 \
#     libxtst6 \
#     libxrandr2 \
#     libasound2 \
#     libxkbcommon-x11-0 \
#     x11-apps \
#     wget \
#     gstreamer1.0-plugins-bad \
#     gstreamer1.0-libav \
#     gstreamer1.0-gl \
#     libfuse2 \
#     libxcb-xinerama0 \
#     libxkbcommon-x11-0 \
#     libxcb-cursor-dev \
#     && rm -rf /var/lib/apt/lists/*

# EXPOSE 80

# # Download prebuilt QGroundControl AppImage
# RUN wget https://d176tv9ibo4jno.cloudfront.net/latest/QGroundControl-x86_64.AppImage -O /usr/local/bin/qgc \
#     && chmod +x /usr/local/bin/qgc

# CMD ["/usr/local/bin/qgc"]

FROM ubuntu:22.04

# Deps
RUN apt-get update && apt-get install -y \
  ca-certificates wget x11-apps \
  libopengl0 libglu1-mesa libgl1-mesa-dri mesa-vulkan-drivers \
  libgl1-mesa-glx libglib2.0-0 libpulse0 libx11-xcb1 libnss3 \
  libxcomposite1 libxcursor1 libxdamage1 libxi6 libxtst6 libxrandr2 \
  libasound2 libxkbcommon-x11-0 \
  && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
  libegl1 libgles2 libglvnd0 libgl1-mesa-dri mesa-vulkan-drivers \
  && ldconfig


EXPOSE 80

# Get AppImage and EXTRACT it (no FUSE needed at runtime)
WORKDIR /opt/qgc
RUN wget https://d176tv9ibo4jno.cloudfront.net/latest/QGroundControl-x86_64.AppImage -O QGC.AppImage && \
    chmod +x QGC.AppImage && \
    ./QGC.AppImage --appimage-extract && \
    ln -s /opt/qgc/squashfs-root/AppRun /usr/local/bin/qgc

# Run
CMD ["qgc"]





