#!/bin/bash

# Check if root
if [[ $EUID -ne 0 ]]; then
	echo "Must be run as root" 1>&2
	exit 1
fi

# Set variable as current directory (absolute path)
export DOCKER_INSTALL_DIR=$(pwd)

# Install docker if not already installed:

apt-get install -y docker;

# Pull build from docker hub repo:

docker build -rm=true -t DOCKER_INSTALL_DIR .

# Docker image should be built

# Place a file to indicate image exists

touch DOCKER_INSTALL_DIR/.docker_build_true
