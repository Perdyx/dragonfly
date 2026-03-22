# Author: Per
# Description: Blockchain development and smart contract auditing platform
    
FROM debian:stable

EXPOSE 22
EXPOSE 8545

SHELL ["/bin/bash", "-lc"]
ARG PASSWORD=dragonfly
ENV DEBIAN_FRONTEND=noninteractive

# Update and install required apt packages and clean apt cache
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    openssh-server \
    python3 \
    python3-dev \
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

# Set up the PATH variable for the dragonfly user
RUN echo "export PATH=/home/dragonfly/.foundry/bin:$PATH" >> /home/dragonfly/.bashrc

# Set up tmux
COPY --chown=dragonfly:dragonfly ./tmux.conf /home/dragonfly/.tmux.conf

# Install NVM, Node.js/NPM v24, yarn
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash \
    && source /home/dragonfly/.nvm/nvm.sh && nvm install 24 \
    && npm install --global yarn

# Install Foundry using the official script
RUN curl -L https://foundry.paradigm.xyz | bash \
    && /home/dragonfly/.foundry/bin/foundryup

# Install Slither
RUN uv tool install slither-analyzer

# Install Mythril
RUN uv tool install mythril

# Set up the workspace
WORKDIR /home/dragonfly/workspace

CMD bash -c "uv tool update-shell && sudo ssh-keygen -A && sudo /usr/sbin/sshd -D"
