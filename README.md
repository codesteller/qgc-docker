# QGroundControl Docker Project

A comprehensive CMake-based build system for running QGroundControl in Docker containers with support for GUI forwarding, GPU acceleration, and serial device access.

## 🚀 Quick Start

The fastest way to get started is using the quick start script:

```bash
./scripts/quick-start.sh
```

This script will:
1. Check system requirements
2. Setup X11 permissions
3. Configure CMake build
4. Build Docker image
5. Run QGroundControl

## 📋 Prerequisites

- **Docker** - Container runtime
- **CMake** (3.16+) - Build system
- **X11 or Wayland** - For GUI applications (optional for headless)
- **NVIDIA GPU** (optional) - For hardware acceleration

### System Check

Run the system check script to verify your setup:

```bash
./scripts/check-system.sh
```

## 🔧 Building the Project

### 1. Configure CMake

Choose one of the predefined configurations:

```bash
# Development configuration (all features enabled)
mkdir build && cd build
cmake .. -C ../config/development.cmake

# Production configuration (conservative settings)
cmake .. -C ../config/production.cmake

# Headless configuration (for servers)
cmake .. -C ../config/headless.cmake

# Custom configuration
cmake .. -DENABLE_GPU=ON -DSERIAL_DEVICE=/dev/ttyUSB0
```

### 2. Build and Run

```bash
# Build the Docker image
make docker-build

# Run QGroundControl (auto-detects display type)
make docker-run

# Run with explicit GUI forwarding
make docker-run-gui

# Run in headless mode (accessible via VNC on port 5900)
make docker-run-headless
```

## 🎯 Available CMake Targets

| Target | Description |
|--------|-------------|
| `docker-build` | Build the Docker image |
| `docker-run` | Run QGroundControl (auto-detect display) |
| `docker-run-gui` | Run with explicit GUI forwarding |
| `docker-run-headless` | Run in headless mode (VNC) |
| `docker-stop` | Stop and remove container |
| `docker-clean` | Clean Docker image and container |
| `docker-logs` | Follow container logs |
| `docker-shell` | Open shell in container for debugging |
| `setup-x11` | Setup X11 permissions for Docker |
| `compose-up` | Start services with Docker Compose |
| `compose-down` | Stop Docker Compose services |
| `help` | Show all available targets |

## ⚙️ Configuration Options

Configure the build using CMake variables:

```bash
cmake .. \
  -DDOCKER_IMAGE_NAME=qgc \
  -DDOCKER_IMAGE_TAG=latest \
  -DENABLE_GPU=ON \
  -DENABLE_DISPLAY=ON \
  -DENABLE_NETWORK_HOST=ON \
  -DENABLE_SERIAL_DEVICES=ON \
  -DSERIAL_DEVICE=/dev/ttyUSB0
```

### Configuration Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DOCKER_IMAGE_NAME` | `qgc` | Docker image name |
| `DOCKER_IMAGE_TAG` | `latest` | Docker image tag |
| `DOCKER_CONTAINER_NAME` | `qgc-container` | Container name |
| `ENABLE_GPU` | `ON` | Enable NVIDIA GPU support |
| `ENABLE_DISPLAY` | `ON` | Enable X11/Wayland display forwarding |
| `ENABLE_NETWORK_HOST` | `ON` | Use host networking |
| `ENABLE_SERIAL_DEVICES` | `ON` | Enable serial device access |
| `SERIAL_DEVICE` | `/dev/ttyUSB0` | Primary serial device path |
| `DISPLAY_RESOLUTION` | `1280x720x24` | Display resolution for headless mode |

## 🐳 Docker Compose

Alternative orchestration using Docker Compose:

```bash
# Copy environment configuration (optional)
cp .env.example .env

# Start default service
docker-compose up qgc

# Start with GPU support
docker-compose -f docker-compose.yml -f docker-compose.gpu.yml up qgc

# Start VNC service for headless operation
docker-compose --profile vnc up qgc-vnc

# Start development service
docker-compose --profile development up qgc-dev

# Build and start all services
docker-compose up --build
```

### Environment Configuration

Copy `.env.example` to `.env` and customize:

```bash
# User configuration (matches host user to avoid permission issues)
UID=1000
GID=1000

# QGroundControl version
QGC_DOWNLOAD_LINK=https://d176tv9ibo4jno.cloudfront.net/latest/QGroundControl-x86_64.AppImage
```

## 📁 Project Structure

```
qgc/
├── CMakeLists.txt              # Main CMake configuration
├── Dockerfile                  # Docker image definition
├── docker-compose.yml          # Docker Compose configuration
├── README.md                   # This file
├── QGroundControl_Docker_Guide.md  # Detailed Docker guide
├── cmake/
│   └── Docker.cmake           # CMake Docker utilities
├── config/
│   ├── development.cmake      # Development preset
│   ├── production.cmake       # Production preset
│   └── headless.cmake         # Headless preset
├── scripts/
│   ├── quick-start.sh         # Quick start script
│   ├── check-system.sh        # System requirements check
│   └── setup-x11.sh           # X11 permissions setup
├── data/
│   ├── QGCSettings/           # Persistent QGC configuration
│   └── QGCData/               # Persistent QGC data
└── build/                     # CMake build directory
    └── docker/
        ├── run-qgc.sh         # Generated run script
        ├── run-qgc-gui.sh     # Generated GUI run script
        └── run-qgc-headless.sh # Generated headless run script
```

## 🖥️ Display Forwarding

### X11 (Linux)

```bash
# Setup X11 permissions
xhost +local:docker

# Run with GUI
make docker-run-gui
```

### Wayland (Linux)

Wayland support is automatically detected. The build system handles:
- `WAYLAND_DISPLAY` environment variable
- `XDG_RUNTIME_DIR` socket mounting

### Headless/VNC (Servers)

```bash
# Run in headless mode
make docker-run-headless

# Connect with VNC client to localhost:5900
```

## 🔌 Hardware Access

### Serial Devices

The system automatically detects and provides access to:
- `/dev/ttyUSB*` (USB-to-serial adapters)
- `/dev/ttyACM*` (Arduino-compatible devices)

If you need specific device access:

```bash
cmake .. -DSERIAL_DEVICE=/dev/ttyACM0
```

### GPU Acceleration

NVIDIA GPU support is automatically enabled if available:

```bash
# Verify GPU support
nvidia-smi
docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi

# Build with GPU support
cmake .. -DENABLE_GPU=ON
```

## 🐞 Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| `QXcbConnection: Could not connect to display` | Run `./scripts/setup-x11.sh` |
| Serial device not found | Check device permissions: `sudo usermod -a -G dialout $USER` |
| GPU not working | Install nvidia-docker2 |
| Container won't start | Check Docker daemon: `sudo systemctl start docker` |

### Debug Commands

```bash
# Check container logs
make docker-logs

# Open shell in container
make docker-shell

# System requirements check
./scripts/check-system.sh
```

## 🔒 Security Notes

- **Non-root user**: Container runs as `qgcuser` (UID/GID 1000 by default) for better security
- **Host networking**: Used for MAVLink UDP access - consider network isolation for production
- **Device access**: Serial devices are mounted directly into the container
- **X11 sharing**: X11 socket is shared for GUI access
- **User mapping**: UID/GID can be customized to match host user and avoid permission issues

### User ID Mapping

To avoid permission issues with mounted volumes:

```bash
# Set your user ID in docker-compose
export UID=$(id -u)
export GID=$(id -g)
docker-compose up qgc

# Or set in .env file
echo "UID=$(id -u)" >> .env
echo "GID=$(id -g)" >> .env
```

## 📖 Additional Documentation

- [QGroundControl Docker Guide](QGroundControl_Docker_Guide.md) - Detailed Docker setup and troubleshooting
- [QGroundControl Official Docs](https://docs.qgroundcontrol.com/)
- [MAVLink Protocol](https://mavlink.io/en/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `./scripts/check-system.sh`
5. Submit a pull request

## 📄 License

This project follows the same license as QGroundControl.

---

**Author:** Dr. Pallab Maji  
**Last Updated:** October 2025

**Quick Commands:**
```bash
# Get started immediately
./scripts/quick-start.sh

# Build and run manually  
mkdir build && cd build && cmake .. && make docker-build && make docker-run
```