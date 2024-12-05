#!/bin/bash

# Variables

: ${HOSTNAME:=devbox}

: ${USERNAME:=devbox}
: ${PASSWORD:?"Error: PASSWORD environment variable is not set."}

: ${ROOT_PASSWORD:?"Error: ROOT_PASSWORD environment variable is not set."}
: ${CS_PASSWORD:?"Error: CS_PASSWORD environment variable is not set."}

: ${AUTHORIZED_KEYS:=""}

: ${GIT_USERNAME:=""}
: ${GIT_EMAIL:=""}

# Set the hostname
hostname ${HOSTNAME}

# Set the root password
echo "root:${ROOT_PASSWORD}" | chpasswd

# Create the user with the provided username and set the password
if id "${USERNAME}" &>/dev/null; then
    echo "${USERNAME}:${PASSWORD}" | chpasswd
    echo "User ${USERNAME} already exists"
else
    useradd -ms /bin/bash "${USERNAME}"
    echo "${USERNAME}:${PASSWORD}" | chpasswd
    echo "User ${USERNAME} created with the provided password"
fi

# Create home and workspace folders
mkdir -p /home/${USERNAME}/workspace
chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

# Configure git
if [ -n "${GIT_USERNAME}" ]; then
    su ${USERNAME} -c 'git config --global user.name "${GIT_USERNAME}"'
fi

if [ -n "${GIT_EMAIL}" ]; then
    su ${USERNAME} -c 'git config --global user.email "${GIT_EMAIL}"'
fi

# Start code-server
su ${USERNAME} -c 'PASSWORD=${CS_PASSWORD} nohup code-server --bind-addr=0.0.0.0:8080 --app-name=devbox --auth=password &'

# Create .ssh folder
mkdir -p /home/${USERNAME}/.ssh
chmod 700 /home/${USERNAME}/.ssh
chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.ssh

# Set the authorized keys from the AUTHORIZED_KEYS environment variable (if provided)
if [ -n "${AUTHORIZED_KEYS}" ]; then
    echo "${AUTHORIZED_KEYS}" > /home/${USERNAME}/.ssh/authorized_keys
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.ssh
    chmod 600 /home/${USERNAME}/.ssh/authorized_keys
    echo "Authorized keys set for user ${USERNAME}"
fi

# Start the SSH server
echo "Starting SSH server..."
exec /usr/sbin/sshd -D