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

# Set timezone
RUN ln -fs /usr/share/zoneinfo/Asia/Taipei /etc/localtime && \
    apt update && apt install -y tzdata && \
    dpkg-reconfigure -f noninteractive tzdata && \
    rm -rf /var/lib/apt/lists/*

# Create user
ARG USERNAME=XXXX
ARG PASSWORD=XXXX
RUN useradd -m ${USERNAME} -s /bin/bash && \
    echo "${USERNAME}:${PASSWORD}" | chpasswd && \
    usermod -aG sudo ${USERNAME}

# Enable auto-login to tty1 for user
RUN mkdir -p /etc/systemd/system/getty@tty1.service.d && \
    printf "[Service]\nExecStart=\nExecStart=-/sbin/agetty --autologin dennis --noclear %%I \$TERM\n" \
    > /etc/systemd/system/getty@tty1.service.d/override.conf

# Configure bash
RUN cp /etc/skel/.bashrc /home/${USERNAME}/.bashrc && \
    cp /etc/skel/.profile /home/${USERNAME}/.profile && \
    echo "source /etc/bash.bashrc" >> /home/${USERNAME}/.bashrc && \
    chown ${USERNAME}:${USERNAME} /home/${USERNAME}/.bashrc /home/${USERNAME}/.profile

# Set hostname
RUN echo "ubuntu-dev" > /etc/hostname

# Enable systemd in Docker
STOPSIGNAL SIGRTMIN+3
VOLUME [ "/sys/fs/cgroup" ]
WORKDIR /home/${USERNAME}
USER dennis
CMD ["bash"]
