<!--
* @ Copyright: @copyright (c) 2025 Gahan AI Private Limited
* @ Author: Pallab Maji
* @ Create Time: 2025-10-31 10:44:33
* @ Modified time: 2025-10-31 16:15:00
* @ Description: Comprehensive Docker guide for QGroundControl deployment
-->

# Running QGroundControl (QGC) Inside Docker

QGroundControl (QGC) is a Qt-based Ground Station for MAVLink-based drones and vehicles.  
You can run QGC inside a Docker container for isolation, portability, and easy deployment —  
but GUI forwarding and hardware access require a few extra steps.

---

## 🧩 1. Overview

QGC can run in Docker if you properly configure:

- **Display access** (X11 or Wayland)
- **Serial/UDP access** for MAVLink connections
- **Optional GPU acceleration** for smooth 3D rendering
- **Persistent configuration storage** if you want QGC settings saved between runs

---

## 🐳 2. Example Dockerfile

```dockerfile
FROM ubuntu:22.04

# Install QGC dependencies
RUN apt-get update && apt-get install -y     libgl1-mesa-glx     libglib2.0-0     libpulse0     libx11-xcb1     libnss3     libxcomposite1     libxcursor1     libxdamage1     libxi6     libxtst6     libxrandr2     libasound2     libxkbcommon-x11-0     x11-apps     wget     && rm -rf /var/lib/apt/lists/*

# Download QGroundControl AppImage
RUN wget https://d176tv9ibo4jno.cloudfront.net/latest/QGroundControl.AppImage -O /usr/local/bin/qgc     && chmod +x /usr/local/bin/qgc

CMD ["/usr/local/bin/qgc"]
```

Build the image:
```bash
docker build -t qgc:latest .
```

---

## 💻 3. Running QGC (Local Display, Linux)

```bash
xhost +local:docker

docker run -it --rm     --env="DISPLAY=$DISPLAY"     --net=host     --device=/dev/ttyUSB0     -v /tmp/.X11-unix:/tmp/.X11-unix     qgc:latest
```

### ✅ For GPU acceleration
```bash
docker run -it --rm     --gpus all     --env="QT_X11_NO_MITSHM=1"     --env="DISPLAY=$DISPLAY"     --net=host     -v /tmp/.X11-unix:/tmp/.X11-unix     qgc:latest
```

---

## 🌐 4. Running QGC Headlessly (Remote Access)

If your host has no display (e.g., Jetson, server, VM), use **VNC** or **Xpra**.

### Example with VNC
```bash
apt install -y x11vnc xvfb fluxbox
xvfb-run -s "-screen 0 1280x720x24" /usr/local/bin/qgc
```

Then connect via VNC viewer to port `5900`.

Alternatively:
- **Xpra** (faster, low-latency)
- **VirtualGL + TurboVNC** for OpenGL-accelerated remote display

---

## 🔌 5. MAVLink Access

Add device access for serial links:
```bash
--device=/dev/ttyUSB0
--device=/dev/ttyACM0
```

For UDP-based MAVLink:
```bash
--net=host
```

---

## ⚙️ 6. Docker Compose Example

```yaml
version: "3.8"
services:
  qgc:
    image: qgc:latest
    network_mode: host
    environment:
      - DISPLAY=${DISPLAY}
    devices:
      - /dev/ttyUSB0:/dev/ttyUSB0
    volumes:
      - /tmp/.X11-unix:/tmp/.X11-unix
      - ./QGCSettings:/root/.config/QGroundControl.org
    runtime: nvidia
```

Launch it:
```bash
docker compose up
```

---

## 🚧 7. Common Issues & Fixes

| Issue | Cause | Fix |
|-------|--------|------|
| `QXcbConnection: Could not connect to display` | No X11 forwarding | Use `-v /tmp/.X11-unix:/tmp/.X11-unix` and `-e DISPLAY` |
| Blank/slow map view | No GPU or software renderer | Use `--gpus all` or install `mesa-utils` |
| Serial devices not detected | Device not passed to container | Add `--device=/dev/ttyUSB0` |
| QGC settings reset each run | No persistent volume | Mount `/root/.config/QGroundControl.org` |
| Permission denied to access serial | Missing group permission | Add `--privileged` or match group IDs |

---

## 🧠 8. Tips

- You can mount logs or missions by adding `-v ~/QGCData:/root/Documents/QGroundControl`
- Add `--privileged` if USB devices fail to connect (especially on Jetson)
- For faster UI response, use hardware acceleration (`--gpus all`) and `QT_X11_NO_MITSHM=1`
- For reproducible deployments, pin a specific QGC version AppImage URL

---

## 📦 9. Example One-Liner (GPU + USB + Display)

```bash
docker run -it --rm     --gpus all     --net=host     --device=/dev/ttyUSB0     -e DISPLAY=$DISPLAY     -v /tmp/.X11-unix:/tmp/.X11-unix     -v ./QGCSettings:/root/.config/QGroundControl.org     qgc:latest
```

---

## 🧾 10. References

- [QGroundControl Official Docs](https://docs.qgroundcontrol.com/)
- [MAVLink Protocol Spec](https://mavlink.io/en/)
- [Qt & X11 Forwarding Guide](https://wiki.qt.io/X11_forwarding)
- [Docker GPU Support](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)

---

**Author:** Dr. Pallab Maji  
**Last Updated:** October 2025  
