#!/bin/bash

set -e

echo "=== Installing prerequisites (curl, tar) ==="
sudo apt-get update -y
sudo apt-get install -y curl tar

echo "=== Installing eksctl ==="

# Download latest eksctl binary directly from GitHub releases
curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" -o eksctl.tar.gz

# Extract and move binary to /usr/local/bin
tar -xzf eksctl.tar.gz
sudo mv eksctl /usr/local/bin

# Verify installation
eksctl version

echo "=== eksctl installation complete ==="

