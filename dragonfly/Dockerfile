# Author: Per
# Description: Blockchain development and smart contract auditing platform
    
FROM debian:stable

EXPOSE 22
SHELL ["/bin/bash", "-lc"]
ARG PASSWORD
ENV DEBIAN_FRONTEND=noninteractive

# Update and install required apt packages and clean apt cache
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    openssh-server \
    python3 \
    sudo \
    tmux \
    vim \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Astral UV by copying the executables directly from the official image
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Generate SSH host keys (must be done as root before switching user)
RUN ssh-keygen -A

# Create a new user "dragonfly" with sudo privileges (no password required)
RUN groupadd -g 1000 dragonfly \
    && useradd -u 1000 -g dragonfly -m dragonfly \
    && usermod -s /bin/bash dragonfly \
    && echo "dragonfly:$PASSWORD" | chpasswd \
    && echo "dragonfly ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER dragonfly

# Create projects directory to be shared with the host for selective data persistence
RUN mkdir -p /home/dragonfly/projects

# Set up the PATH variable for the dragonfly user
RUN echo "export PATH=/home/dragonfly/.foundry/bin:$PATH" >> /home/dragonfly/.bashrc

# Set up tmux
COPY --chown=dragonfly:dragonfly ./tmux.conf /home/dragonfly/.tmux.conf

# Install NVM and Node.js/NPM v24
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash \
    && source /home/dragonfly/.nvm/nvm.sh && nvm install 24

# Install Foundry using the official script
RUN curl -L https://foundry.paradigm.xyz | bash \
    && /home/dragonfly/.foundry/bin/foundryup

CMD bash -c "sudo chown -R dragonfly:dragonfly /home/dragonfly/projects && sudo ssh-keygen -A && sudo /usr/sbin/sshd -D"
