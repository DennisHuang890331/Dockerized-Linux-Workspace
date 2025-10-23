# Dockerized Linux Workspace for Development (Windows Host)

This project provides a tutorial for building a simple Linux workspace using docker with the folowing features.


- Ubuntu 22.04 base environment
- Integration with Windows host directories
- GPU support using `--gpus all`
- Customizable Linux user and password
- Timezone set to Asia/Taipei

---

## Requirements (Windows Only)

Before you begin, ensure the following are installed and configured **on your Windows machine**:

| Component                  | Requirement                                      |
|----------------------------|--------------------------------------------------|
| Docker Desktop             | Installed with WSL2 backend                      |
| NVIDIA GPU                 | Optional, for GPU compute                        |
| NVIDIA Driver              | Must be installed on the host                    |
| NVIDIA Container Toolkit   | Enabled via Docker Desktop                       |
| Windows Host Folder Access | Drive D must be shared in Docker Desktop         |

---

## Step 1: Prepare Host Storage (Persistent Volume)

Create a folder on Windows that will persist user data from inside the container:

```
D:\Ubuntu2204
```

This folder will be mounted inside the Docker container as `/home/<username>`.

---

## Step 2: Create Docker Volume (Bind Mount to Windows Folder)

Create a named Docker volume that points to the Windows folder:

```powershell
docker volume create --name ubuntu2204 --opt type=none --opt device=D:\Ubuntu2204 --opt o=bind
```

---

## Step 3: Configure Dockerfile

Create a `Dockerfile` in your project directory. At the top of the file, set:

```Dockerfile
ARG USERNAME=XXXX
ARG PASSWORD=XXXX
```

You may modify these values to customize your default user. The Dockerfile automatically:

- Creates a Linux user with home directory
- Enables sudo with password
- Sets Bash shell with `.bashrc`
- Applies Asia/Taipei timezone
- GUI seeting with x11

**Note! User should install [x410](https://www.microsoft.com/store/productId/9PM8LP83G3L3?ocid=libraryshare) in Microsoft store.**

---

## Step 4: Build the Docker Image

Run this command inside the directory where the Dockerfile is located:

```powershell
docker build -t ubuntu2204:dev .
```

---

## Step 5: Run the Docker Container

Use this command to start a container with full hardware access (GPU + USB + Serial) and a persistent home directory:

```powershell
docker run -it --privileged --name ubuntu2204 --hostname ubuntu-dev --gpus all --device /dev:/dev -e DISPLAY=host.docker.internal:0.0 -e QT_XCB_FORCE_SOFTWARE_OPENGL=1 -v ubuntu2204:/home/$USERNAME ubuntu2204:dev
````

* `--privileged` enables full hardware access inside Docker
* `--device /dev:/dev` allows USB devices and sensors (e.g. RealSense, serial, LiDAR)
* `--gpus all` enables NVIDIA GPU support
* `-v ubuntu2204:/home/$USERNAME` mounts persistent user data
- **Remember to change your [$USERNAME](https://github.com/NTU-iEV-M-Lab/Dockerized-Linux-Workspace/blob/main/Dockerfile#L33)**

---

## Step 6: Initilize your working space
Remember update & upgrade your environment when first login.
```bash
sudo apt update && sudo apt upgrade
```

## Step 7: Restart the Environment

To re-enter the container later:

```powershell
docker start -ai ubuntu2204
```

Your work will be preserved thanks to the mounted volume.

