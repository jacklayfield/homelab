#!/bin/bash

set -e

echo "Updating system..."
sudo apt update

echo "Installing Docker..."
sudo apt install -y docker.io docker-compose

echo "Starting Docker..."
sudo systemctl enable docker
sudo systemctl start docker

echo "Adding user to docker group..."
sudo usermod -aG docker $USER

echo "Done. You may need to log out and back in."