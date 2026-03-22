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

The following commands can be used to bring the stack up or down:

```sh
$ docker compose up -d
$ docker compose down
```

Actually using the container can be done in one of two ways. In both cases, use the password you set in the .env file to login.

### SSH direct access

SSH into the `dragonfly` user:

`$ ssh dragonfly@localhost -p 3333`

### VS Code attach session

Download and install the following VS Code extensions:

- https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh
- https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers

Click on the `><` button in the lower left corner of VS Code. In the menu that opens, click "Attach to Running Container..." and follow the prompts. Once connected, open `/home/dragonfly/projects` as your workspace.