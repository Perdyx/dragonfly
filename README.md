# Dragonfly

Dragonfly is a toolkit for Solidity blockchain development and smart contract auditing contained in a Docker image.

## Setup

Create a `.env` file alongside `docker-compose.yaml` with the following contents:

```
PASSWORD="<dragonfly user password>"
```

To build the image, run the build script.

`$ ./build`

## Usage

The following scripts can be used to bring the stack up or down:

```
$ ./start
$ ./stop
```

Actually using the container can be done in one of two ways. Use the password you set in the .env file to login in both cases.

### SSH direct access

SSH into the `dragonfly` user:

`$ ssh dragonfly@localhost -p 3333`

### VS Code attach session

Download and install the following VS Code extensions:

- https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh
- https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers

Click on the `><` button in the lower left corner of VS Code. In the menu that opens, click "Attach to Running Container..." and follow the prompts. Once connected, open `/home/dragonfly/projects` as your workspace.