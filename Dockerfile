# ===== Dockerfile =====
FROM nvidia/cuda:12.4.1-base-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV container docker

# Install systemd and basic tools
RUN apt update && \
    apt install -y systemd systemd-sysv dbus dbus-user-session sudo passwd bash-completion net-tools iputils-ping curl wget nano && \
    apt clean && rm -rf /var/lib/apt/lists/* 

RUN apt update && apt install -y command-not-found && \
    sed -i 's/^if command -v command-not-found-handler/#&/' /etc/zsh/zshrc /etc/bash.bashrc || true && \
    apt update && update-command-not-found || true

# --- GUI / X11 / OpenGL / Qt / Wireshark ---
RUN apt update && apt install -y \
    wireshark x11-apps mesa-utils \
    libgl1-mesa-glx libglu1-mesa \
    libx11-xcb1 libxkbcommon-x11-0 libxrender1 libxext6 libsm6 libxi6 \
    libxcb1 libxcb-render0 libxcb-shape0 libxcb-xfixes0 libxcb-randr0 \
    libxcb-keysyms1 libxcb-image0 libxcb-icccm4 libxcb-util1 libxcb-xinerama0 libxcb-glx0 \
 && apt clean && rm -rf /var/lib/apt/lists/*
# 可選：某些 Qt 場景更穩
ENV QT_XCB_FORCE_SOFTWARE_OPENGL=1

# Set timezone
RUN ln -fs /usr/share/zoneinfo/Asia/Taipei /etc/localtime && \
    apt update && apt install -y tzdata && \
    dpkg-reconfigure -f noninteractive tzdata && \
    rm -rf /var/lib/apt/lists/*

# Create user
ARG USERNAME=xxxx
ARG PASSWORD=xxxx

RUN useradd -m ${USERNAME} -s /bin/bash && \
    echo "${USERNAME}:${PASSWORD}" | chpasswd && \
    usermod -aG sudo ${USERNAME}

# Enable auto-login to tty1 for user
RUN mkdir -p /etc/systemd/system/getty@tty1.service.d && \
    printf "[Service]\nExecStart=\nExecStart=-/sbin/agetty --autologin dennis --noclear %%I \$TERM\n" \
    > /etc/systemd/system/getty@tty1.service.d/override.conf

# ----- Configure bash and add custom .bashrc settings for ${USERNAME} and root -----
RUN cp /etc/skel/.bashrc /home/${USERNAME}/.bashrc \
 && cp /etc/skel/.profile /home/${USERNAME}/.profile \
 && echo "source /etc/bash.bashrc" >> /home/${USERNAME}/.bashrc \
 && echo '' >> /home/${USERNAME}/.bashrc \
 && echo '# ===== Custom settings =====' >> /home/${USERNAME}/.bashrc \
 && echo 'export LANG=C.UTF-8' >> /home/${USERNAME}/.bashrc \
 && echo 'export DISPLAY=${DISPLAY:-host.docker.internal:0.0}' >> /home/${USERNAME}/.bashrc \
 && echo 'export QT_XCB_FORCE_SOFTWARE_OPENGL=1' >> /home/${USERNAME}/.bashrc \
 && echo 'if [ -x /usr/lib/command-not-found ]; then' >> /home/${USERNAME}/.bashrc \
 && echo '    function command_not_found_handle {' >> /home/${USERNAME}/.bashrc \
 && echo '        /usr/lib/command-not-found -- "$1"' >> /home/${USERNAME}/.bashrc \
 && echo '    }' >> /home/${USERNAME}/.bashrc \
 && echo 'fi' >> /home/${USERNAME}/.bashrc \
 && echo '# ===== End custom settings =====' >> /home/${USERNAME}/.bashrc \
 && cp /home/${USERNAME}/.bashrc /root/.bashrc \
 && chown ${USERNAME}:${USERNAME} /home/${USERNAME}/.bashrc /home/${USERNAME}/.profile


# Set hostname
RUN echo "ubuntu-dev" > /etc/hostname

# Enable systemd in Docker
STOPSIGNAL SIGRTMIN+3
VOLUME [ "/sys/fs/cgroup" ]
WORKDIR /home/${USERNAME}
USER ${USERNAME}
CMD ["bash"]
