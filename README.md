# Dragonfly

Dragonfly is a toolkit for Solidity blockchain development and smart contract auditing contained in a Docker image.

## Setup

Create a `.env` file alongside `docker-compose.yaml` with the following contents:

```
PASSWORD="<dragonfly user password>"
```

Build the Docker image:

`$ docker compose build`

## Usage

The following commands can be used to start and stop the container:

```sh
$ docker compose up -d
$ docker compose down
```

Accessing the container can be done in one of two ways. In both cases, use the password you set in the .env file to login. If you did not set a password, the default is `dragonfly`.

### SSH direct access

***WARNING**: If you do not need remote access to the container, **turn this off**. This can be done by commenting out or removing the `- "3333:22"` line in `docker-compose.yaml`.*

SSH is enabled by default to provide remote access in server-based deployments. To access the `dragonfly` user run the following from your terminal once the container is running:

`$ ssh dragonfly@localhost -p 3333`

### VS Code attach session

Download and install the following VS Code extensions:

- https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh
- https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers

Click on the `><` button in the lower left corner of VS Code. In the menu that opens, click "Attach to Running Container..." and follow the prompts. Once connected, open `/home/dragonfly/projects` as your workspace.