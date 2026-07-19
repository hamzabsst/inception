#!/bin/bash

set -e

echo "Updating system..."
sudo apt update
sudo apt upgrade -y

echo "Installing dependencies..."
sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git \
    make \
    tree \
    openssl \
    mariadb-client

echo "Installing Docker..."

# Remove old Docker packages
sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

# Docker GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
| sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Docker repository
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

echo "Installing Docker Engine..."
sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

echo "Adding current user to docker group..."
sudo usermod -aG docker "$USER"

echo "Starting Docker..."
sudo systemctl enable docker
sudo systemctl start docker

echo
echo "========================================="
echo "Installation completed!"
echo "========================================="
echo
echo "Log out and log back in (or reboot) before using Docker without sudo."
echo
echo "Verify with:"
echo "docker --version"
echo "docker compose version"
echo