FROM ubuntu:22.04

# ====== User Configuration ======
ARG USERNAME=dennis
ARG PASSWORD=zxcvb22661560
# =================================

ENV DEBIAN_FRONTEND=noninteractive

# Set timezone
RUN ln -fs /usr/share/zoneinfo/Asia/Taipei /etc/localtime && \
    apt update && apt install -y tzdata sudo passwd && \
    dpkg-reconfigure -f noninteractive tzdata

# Create user with password
RUN useradd -m $USERNAME -s /bin/bash && \
    echo "$USERNAME:$PASSWORD" | chpasswd && \
    usermod -aG sudo $USERNAME

# Setup .bashrc with colors and alias
RUN cp /etc/skel/.bashrc /home/$USERNAME/.bashrc && \
    cp /etc/skel/.profile /home/$USERNAME/.profile && \
    chown $USERNAME:$USERNAME /home/$USERNAME/.bashrc /home/$USERNAME/.profile

# Switch to user
USER $USERNAME
WORKDIR /home/$USERNAME
SHELL ["/bin/bash", "-c"]
