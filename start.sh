#!/bin/bash

set -e

# Variables

: ${USERNAME:=devbox}
: ${GROUPNAME:="${USERNAME}"}
: ${PASSWORD:?"Error: PASSWORD environment variable is not set."}
: ${UID:=""}
: ${GID:=""}

: ${ROOT_PASSWORD:?"Error: ROOT_PASSWORD environment variable is not set."}
: ${CS_PASSWORD:=""}

: ${AUTHORIZED_KEYS:=""}

: ${GIT_USERNAME:=""}
: ${GIT_EMAIL:=""}

: ${SETUP_SCRIPT:="/home/${USERNAME}/.devbox/setup.sh"}

# Set the root password
echo "Set root password"
echo "root:${ROOT_PASSWORD}" | chpasswd

# Create the group with the provided groupname
if [ -n "$(getent group ${GROUPNAME})" ]; then
    echo "Group ${GROUPNAME} already exists"
else
    GROUPADD_OPTIONS=""
    [ -n "${GID}" ] && GROUPADD_OPTIONS="${GROUPADD_OPTIONS} -g ${GID}"

    groupadd ${GROUPADD_OPTIONS} "${GROUPNAME}"
    echo "Group ${GROUPNAME} created"
fi

# Create the user with the provided username
if [ -n "$(getent passwd ${USERNAME})" ]; then
    echo "User ${USERNAME} already exists"
else
    USERADD_OPTIONS="-m -s /bin/bash -g ${GROUPNAME}"
    [ -n "${UID}" ] && USERADD_OPTIONS="${USERADD_OPTIONS} -u ${UID}"

    useradd ${USERADD_OPTIONS} "${USERNAME}"
    echo "User ${USERNAME} created"
fi

# Configure user
echo "Set user password"
echo "${USERNAME}:${PASSWORD}" | chpasswd

echo "Add user to sudoers"
usermod -aG sudo ${USERNAME}
echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USERNAME}
chmod 600 /etc/sudoers.d/${USERNAME}

# Create home and workspace folders
echo "Create home and workspace folders"
mkdir -p /home/${USERNAME}/workspace
chown -R ${USERNAME}:${GROUPNAME} /home/${USERNAME}

# Configure git
if [ -n "${GIT_USERNAME}" ]; then
    echo "Set git username"
    su ${USERNAME} -c "git config --global user.name '${GIT_USERNAME}'"
fi

if [ -n "${GIT_EMAIL}" ]; then
    echo "Set git email"
    su ${USERNAME} -c "git config --global user.email '${GIT_EMAIL}'"
fi

# Start code-server
if [ -n "${CS_PASSWORD}" ]; then
    echo "Start code-server"
    su ${USERNAME} -c "PASSWORD='${CS_PASSWORD}' nohup code-server --bind-addr=0.0.0.0:8080 --app-name=devbox --auth=password &"
fi

# Create .ssh folder
echo "Create .ssh folder"
mkdir -p /home/${USERNAME}/.ssh
chmod 700 /home/${USERNAME}/.ssh
chown -R ${USERNAME}:${GROUPNAME} /home/${USERNAME}/.ssh

# Set the authorized keys from the AUTHORIZED_KEYS environment variable (if provided)
if [ -n "${AUTHORIZED_KEYS}" ] && [ ! -f "/home/${USERNAME}/.ssh/authorized_keys" ]; then
    echo "${AUTHORIZED_KEYS}" > /home/${USERNAME}/.ssh/authorized_keys
    chown -R ${USERNAME}:${GROUPNAME} /home/${USERNAME}/.ssh
    chmod 600 /home/${USERNAME}/.ssh/authorized_keys
    echo "Authorized keys set for user ${USERNAME}"
fi

# Call the setup script
if [ -n "${SETUP_SCRIPT}" ] && [ -f "${SETUP_SCRIPT}" ]; then
    echo "Calling setup script"
    chmod +x ${SETUP_SCRIPT}
    su ${USERNAME} -c ${SETUP_SCRIPT}
fi

# Install the SSH server
echo "Installing SSH server"
apt-get install -y openssh-server
mkdir -p /run/sshd && chmod 755 /run/sshd

# Start the SSH server
echo "Starting SSH server..."
exec /usr/sbin/sshd -D
