#!/bin/bash

sudo -n true
if [ $? -eq 0 ]; then
  echo "The user has root access."
else
  echo "The user does not have root access. Everything required to run the notebook is already installed and setup. We are good to go!"
  exit 0
fi

# Do we have GPU support?
nvidia-smi > /dev/null 2>&1
if [ $? -eq 0 ]; then
  # check if we have nvidia-docker
  NVIDIA_DOCKER=`rpm -qa | grep -c nvidia-docker2`
  if [ $NVIDIA_DOCKER -eq 0 ]; then
    # Install nvidia-docker2
    DOCKER_VERSION=`yum list docker | tail -1 | awk '{print $2}' | head -c 2`

    if [ $DOCKER_VERSION -eq 17 ]; then
      DOCKER_PKG_VERSION='17.09.1ce-1.111.amzn1'
      NVIDIA_DOCKER_PKG_VERSION='2.0.3-1.docker17.09.1.ce.amzn1'
    else
      DOCKER_PKG_VERSION='18.06.1ce-3.17.amzn1'
      NVIDIA_DOCKER_PKG_VERSION='2.0.3-1.docker18.06.1.ce.amzn1'
    fi

    sudo yum -y remove docker
    sudo yum -y install docker-$DOCKER_PKG_VERSION

    sudo /etc/init.d/docker start

    curl -s -L https://nvidia.github.io/nvidia-docker/amzn1/nvidia-docker.repo | sudo tee /etc/yum.repos.d/nvidia-docker.repo
    sudo yum install -y nvidia-docker2-$NVIDIA_DOCKER_PKG_VERSION
    sudo cp daemon.json /etc/docker/daemon.json
    sudo pkill -SIGHUP dockerd
    echo "installed nvidia-docker2"
  else
    echo "nvidia-docker2 already installed. We are good to go!"
  fi
fi