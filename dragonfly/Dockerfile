FROM archlinux:latest

EXPOSE 22
EXPOSE 8545

SHELL ["/bin/bash", "-c"]

ARG PASSWORD
ENV PASSWORD=${PASSWORD}

# Update and install required pacman packages and clean cache
RUN pacman -Syu --noconfirm --needed \
    base-devel \
    ca-certificates \
    curl \
    git \
		jq \
    openssh \
    python \
    sudo \
    tmux \
    vim \
    wget \
 && pacman -Scc --noconfirm

# Install Astral UV by copying the executables directly from the official image
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Generate SSH host keys
RUN ssh-keygen -A

# Create a new user "dragonfly" with sudo privileges (no password required)
RUN groupadd -g 1000 dragonfly \
 && useradd -u 1000 -g dragonfly -m dragonfly \
 && usermod -s /bin/bash dragonfly \
 && echo "dragonfly:$PASSWORD" | chpasswd \
 && echo "dragonfly ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER dragonfly

# Set up PATH for the dragonfly user
ENV PATH="/home/dragonfly/.local/bin:/home/dragonfly/.foundry/bin:${PATH}"
RUN echo "export PATH=\"/home/dragonfly/.local/bin:/home/dragonfly/.foundry/bin:\$PATH\"" >> /home/dragonfly/.bashrc

# Configure tmux
COPY --chown=dragonfly:dragonfly ./tmux.conf /home/dragonfly/.tmux.conf

# Install NVM, Node.js/NPM v24, yarn
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash \
 && source /home/dragonfly/.nvm/nvm.sh && nvm install 24 \
 && npm install --global yarn

# Install Foundry using the official script
RUN curl -L https://foundry.paradigm.xyz | bash \
 && /home/dragonfly/.foundry/bin/foundryup

# Install Slither (force Python 3.12 to prevent breaking on Arch)
RUN uv tool install --python 3.12 slither-analyzer
RUN uv tool install --python 3.12 solc-select

# Install Mythril (force Python 3.12 to avoid coincurve compilation failures)
RUN uv tool install --python 3.12 mythril

# Install custom tooling
COPY --chmod=755 ./harvester.sh /home/dragonfly/harvester.sh
COPY ./.env /home/dragonfly/.env

CMD bash -c "sudo ssh-keygen -A && sudo /usr/bin/sshd -D"