# Use an official Ubuntu base image
FROM ubuntu:24.04

# Arguments
ARG JDK_VERSION="21"
ARG NODE_VERSION="22"

# Avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# APT update
RUN apt update

# Install packages
RUN apt install -y gnupg curl

# Add node sources list
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_VERSION}.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt update

# Install packages
RUN apt install -y git iproute2 iputils-ping nodejs openjdk-${JDK_VERSION}-jdk openssh-server telnet vim

# Install yarn
RUN npm install --global yarn

# Install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Create sshd run directory
RUN mkdir -p /run/sshd \
    && chmod 755 /run/sshd

# Copy the script to configure the user's password and authorized keys
COPY start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh

# Expose SSH port
EXPOSE 22

# Start SSH server
CMD ["/usr/local/bin/start.sh"]