# Description

A docker image based on Ubuntu 24 with the following extra features:
* Pre-installed and configured SSH server (mainly to use with VS Code Remote)
* Running code-server instance

## VS Code Remote

Install VS Code on your local computer and connect to this docker image via SSH with the Remote plugin.

## Code Server

Open a browser and go to `http://[CONTAINER_ADDRESS]:[CODE_SERVER_MAPPED_PORT]`.

Then use the `[CS_PASSWORD]` password.

# Environment Variables

| **Name**        | **Default Value**  | **Required** | **Description**                                                          |
|-----------------|--------------------|--------------|--------------------------------------------------------------------------|
| USERNAME        | devbox             | No           | Your username.  This will also be your username for the SSH connections. |
| PASSWORD        |                    | Yes          | Your password. This will also be your password for the SSH connections.  |
| ROOT_PASSWORD   |                    | Yes          | The root password.                                                       |
| CS_PASSWORD     |                    | No           | The code-server web interface password.                                  |
| AUTHORIZED_KEYS |                    | No           | The list of authorized keys for the SSH connections.                     |
| GIT_USERNAME    |                    | No           | Your git username.                                                       |
| GIT_PASSWORD    |                    | No           | Your git email.                                                          |
| SETUP_SCRIPT    | ~/.devbox/setup.sh | No           | The setup script to execute on startup.                                  |

# Ports

| **Port** | **Description**                     |
|----------|-------------------------------------|
| 22       | The SSH port.                       |
| 8080     | The code-server web interface port. |

# Volumes

| **Path**                   | **Description**                |
|----------------------------|--------------------------------|
| /home/[USERNAME]/.devbox   | To store your devbox scripts.  |
| /home/[USERNAME]/.ssh      | To store your ssh user config. |
| /home/[USERNAME]/workspace | Your workspace folder.         |

# Docker compose

```
services:
  devbox:
    image: ghcr.io/leclercb/devbox:main
    container_name: devbox
    hostname: devbox
    environment:
      - USERNAME=your_username
      - PASSWORD=your_password
      - ROOT_PASSWORD=root_password
      - CS_PASSWORD=code_server_password
      - GIT_USERNAME=git_username
      - GIT_EMAIL=git_email
    volumes:
      - /path/to/.devbox:/home/[USERNAME]/.devbox:rw
      - /path/to/.ssh:/home/[USERNAME]/.ssh:rw
      - /path/to/workspace:/home/[USERNAME]/workspace:rw
    ports:
      - 2022:22
      - 2080:8080
    restart: unless-stopped
```