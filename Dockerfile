# Use an official Ubuntu base image
FROM ubuntu:24.04

# Avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# APT update
RUN apt update

# Install packages
RUN apt install -y gnupg curl

# Add node sources list
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt update

# Install packages
RUN apt install -y git iproute2 iputils-ping nodejs openssh-server telnet vim

# Install yarn
RUN npm install --global yarn

# Create sshd run directory
RUN mkdir -p /run/sshd \
    && chmod 755 /run/sshd

# Copy the script to configure the user's password and authorized keys
COPY configure-ssh-user.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/configure-ssh-user.sh

# Expose SSH port
EXPOSE 22

# Start SSH server
CMD ["/usr/local/bin/configure-ssh-user.sh"]