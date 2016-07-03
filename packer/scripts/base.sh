#!/bin/bash

apt-get update -y
apt-get upgrade -y

apt-get install -y \
        build-essential  \
        git \
        wget \
        dkms \
        apt-transport-https \
        ca-certificates \
        software-properties-common \
        python-apt \
        python-pip \
        curl \
        netcat \
        ngrep \
        dstat \
        nmon \
        iptraf \
        iftop \
        iotop \
        atop \
        mtr \
        tree \
        unzip \
        sysdig \
        git \
        htop \
        jq \
        ntp \
        logrotate \
        dhcping \
        dhcpdump

apt-add-repository ppa:ansible/ansible
apt-get update
apt-get install -y ansible

pip install awscli httpie boto

apt-get dist-upgrade -y
apt-get clean
