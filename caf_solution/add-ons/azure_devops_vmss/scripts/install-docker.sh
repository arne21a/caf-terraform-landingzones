#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive
apt-get update -q

apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
apt update -q

apt install docker-ce
systemctl start docker
