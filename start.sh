#!/bin/bash

# Docker image must exist

if [[ $EUID -ne 0 ]]; then
	echo "Must be started as root" 1>&2
	exit 1
fi

# Get current directory variable
export DOCKER_INSTALL_DIR=$(pwd)

# Port for SSH
export DOCKER_EXTERNAL_PORT=2222

# File to indicate image has been built
DOCKER_BUILD_TRUE=DOCKER_INSTALL_DIR/.docker_build_true

if [ ! -f $DOCKER_BUILD_TRUE ]; then
	echo "No built image, run ./install.sh"
fi

docker run -v 127.0.0.1:$DOCKER_EXTERNAL_PORT:22 -t DOCKER_INSTALL_DIR
