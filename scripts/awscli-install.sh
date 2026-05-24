#!/bin/bash

set -e

echo "=== Installing prerequisites (unzip, curl) ==="
sudo apt-get update -y
sudo apt-get install -y unzip curl

echo "=== Installing AWS CLI v2 ==="

# Remove old AWS CLI if present
sudo rm -rf /usr/local/aws-cli

# Download AWS CLI v2 installer
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Unzip and install
unzip awscliv2.zip
sudo ./aws/install

# Verify installation
aws --version

echo "=== AWS CLI installation complete ==="

