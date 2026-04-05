#!/bin/bash

set -e

log() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

log "Updating package indexes..."
sudo apt-get update -y

if command -v bc &> /dev/null; then
    log "bc is already installed."
else
    log "Installing bc..."
    sudo apt-get install -y bc
fi

if command -v docker &> /dev/null; then
    log "Docker already installed: $(docker --version)"
else
    log "Installing Docker..."
    sudo apt-get install -y docker.io
    sudo systemctl start docker || true
    sudo systemctl enable docker || true
fi

# 3. Docker Compose
if command -v docker-compose &> /dev/null; then
    log "Docker Compose already installed"
else
    log "Installing Docker Compose..."
    sudo apt-get install -y docker-compose
fi

MIN_PYTHON="3.9"

version_ge() {
    printf '%s\n%s\n' "$2" "$1" | sort -C -V
}
if command -v python3 &> /dev/null; then
    VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
    if version_ge "$VERSION" "$MIN_PYTHON"; then
        log "Confirmed: Python $VERSION meets the $MIN_PYTHON+ requirement."
    else
        log "Python $VERSION is too old."
        exit 1
    fi
else
    log "Python3 not found. Installing..."
    sudo apt-get install -y python3
fi

if ! command -v pip3 &> /dev/null; then
    log "Installing pip3..."
    sudo apt-get install -y python3-pip
fi

if python3 -m django --version &> /dev/null; then
    log "Django already installed: $(python3 -m django --version)"
else
    log "Installing Django..."
    pip3 install django --break-system-packages
fi

log "All tools have been successfully installed and tested!"