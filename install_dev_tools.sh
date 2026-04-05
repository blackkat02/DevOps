#!/bin/bash

set -e

log() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

log "Updating package indexes..."
sudo apt-get update -y

if command -v docker &> /dev/null; then
    log "Docker already installed: $(docker --version)"
else
    log "Встановлення Docker..."
    sudo apt-get install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
fi

if command -v docker-compose &> /dev/null; then
    log "Docker Compose already installed: $(docker-compose --version)"
else
    log "Installation Docker Compose..."
    sudo apt-get install -y docker-compose
fi

if ! command -v pip3 &> /dev/null
then
    echo "pip3 not found. Installing..."
    sudo apt-get update -y
    sudo apt-get install -y python3-pip
else
    echo "pip3 already installed."
fi

log "Updating package indexes..."
sudo apt-get update -y

# Додай це тут:
if ! command -v bc &> /dev/null; then
    log "bc not found. Installing bc for version comparison..."
    sudo apt-get install -y bc
fi

if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')

    if (( $(echo "$PYTHON_VERSION >= 3.9" | bc -l) )); then
        log "Python version $PYTHON_VERSION already installed (meets the requirements of 3.9+)."
    else
        log "The installed Python ($PYTHON_VERSION) is out of date. Update..."
        sudo apt-get install -y python3.9
    fi
else
    log "Python not found. Installing Python 3.9..."
    sudo apt-get install -y python3.9
fi

if python3 -m django --version &> /dev/null; then
    log "Django already installed: $(python3 -m django --version)"
else
    log "Installation Django..."
    pip3 install django
fi

log "All tools have been successfully installed and tested!"