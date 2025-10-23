# Dockerized Linux Workspace for Windows Environment

This project provides a concise tutorial for creating a simple Linux workspace using Docker. 

It explains how to set up an Ubuntu 22.04 container on Windows so **undergraduate** and **first-year graduate students** in our lab—who often encounter difficulties installing a native Linux OS as their first step—can learn and use Linux within a familiar Windows environment.

#### **Features**
- Ubuntu 22.04 environment
- Integration with Windows host directories
- GPU support with cuda 12.4.1 and libcudnn9

---

#### Requirements 

Before you begin, ensure the following are installed and configured **on your Windows machine**:

| Component                  | Requirement                                      |
|----------------------------|--------------------------------------------------|
| Docker Desktop             | Installed with WSL2 backend                      |
| NVIDIA GPU                 | Optional, for GPU compute                        |
| NVIDIA Driver              | Must be installed on the host                    |
| NVIDIA Container Toolkit   | Enabled via Docker Desktop                       |
| Windows Host Folder Access | Drive D must be shared in Docker Desktop         |

---

#### Step 1: Prepare persistent host folder and create bound Docker volume

Run these in PowerShell (create folder then create a named Docker volume that binds to it):

```bash
# 1) create host folder (if not exists)
makdir D:\ubuntu2204

# 2) create a named Docker volume that bind-mounts the folder
docker volume create --name ubuntu2204 --opt type=none --opt device='D:\ubuntu2204' --opt o=bind
```

---

#### Step 2 ??Build the image
The Dockerfile will perform the following automatically:

* creates the user and home directory
* grants passwordless `sudo` to that user
* installs and writes the default `~/.bashrc`
* sets timezone to `Asia/Taipei`
* installs X11/Qt libraries required for GUI (container GUI requires host `DISPLAY`)
**Note! You should install [x410](https://www.microsoft.com/store/productId/9PM8LP83G3L3?ocid=libraryshare) in Microsoft store.**

Run in the `Dockerfile` directory:

```bash
docker build -t ubuntu2204 .
```

* `-t ubuntu2204` sets the image name/tag.
* To build with a different default user, pass a build arg:

```bash
docker build -t ubuntu2204 --build-arg USERNAME=$DESIRED_USERNAME .
```


---

###### Step 3: Run the Docker Container

Use this command to start a container with full hardware access (GPU + USB + Serial) and a persistent home directory:

```bash
# To launch docker
docker run -it --privileged --name ubuntu2204 --hostname ubuntu-dev --gpus all --device /dev:/dev -e DISPLAY=host.docker.internal:0.0 -e QT_XCB_FORCE_SOFTWARE_OPENGL=1 -v ubuntu2204:/home/$DESIRED_USERNAME ubuntu2204:dev
# To restart docker
docker start -ia ubuntu2204
````

* `--privileged` enables full hardware access inside Docker
* `--device /dev:/dev` allows USB devices and sensors (e.g. RealSense, serial, LiDAR)
* `--gpus all` enables NVIDIA GPU support
* `-v ubuntu2204:/home/$DESIRED_USERNAME` mounts persistent user data
---