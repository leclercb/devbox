#!/bin/bash

# Set default values for SSH_USERNAME and SSH_PASSWORD if not provided
: ${SSH_USERNAME:=ubuntu}
: ${SSH_PASSWORD:?"Error: SSH_PASSWORD environment variable is not set."}
: ${AUTHORIZED_KEYS:=""}
: ${GIT_USERNAME:=""}
: ${GIT_EMAIL:=""}

# Create the user with the provided username and set the password
if id "$SSH_USERNAME" &>/dev/null; then
    echo "$SSH_USERNAME:$SSH_PASSWORD" | chpasswd
    echo "User $SSH_USERNAME already exists"
else
    useradd -ms /bin/bash "$SSH_USERNAME"
    echo "$SSH_USERNAME:$SSH_PASSWORD" | chpasswd
    echo "User $SSH_USERNAME created with the provided password"
fi

# Configure git
if [ -n "$GIT_USERNAME" ]; then
    su $SSH_USERNAME -c 'git config --global user.name "$GIT_USERNAME"'
fi

if [ -n "$GIT_EMAIL" ]; then
    su $SSH_USERNAME -c 'git config --global user.email "$GIT_EMAIL"'
fi

# Install vscode-server
curl -LO https://raw.githubusercontent.com/b01/dl-vscode-server/refs/tags/0.2.3/download-vs-code.sh
chmod +x download-vs-code.sh
su $SSH_USERNAME -c './download-vs-code.sh "linux" "x64"'

# Create workspace folder
mkdir -p /home/$SSH_USERNAME/workspace
chown -R $SSH_USERNAME:$SSH_USERNAME /home/$SSH_USERNAME/workspace

# Configure ssh
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

# Set the authorized keys from the AUTHORIZED_KEYS environment variable (if provided)
if [ -n "$AUTHORIZED_KEYS" ]; then
    mkdir -p /home/$SSH_USERNAME/.ssh
    echo "$AUTHORIZED_KEYS" > /home/$SSH_USERNAME/.ssh/authorized_keys
    chown -R $SSH_USERNAME:$SSH_USERNAME /home/$SSH_USERNAME/.ssh
    chmod 700 /home/$SSH_USERNAME/.ssh
    chmod 600 /home/$SSH_USERNAME/.ssh/authorized_keys
    echo "Authorized keys set for user $SSH_USERNAME"
    # Disable password authentication if authorized keys are provided
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
fi

# Start the SSH server
echo "Starting SSH server..."
exec /usr/sbin/sshd -D