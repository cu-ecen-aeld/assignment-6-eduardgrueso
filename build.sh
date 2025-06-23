#!/bin/bash
# Script to build image for qemu.
# Author: Siddhant Jajoo.

git submodule init
git submodule sync
git submodule update

set -e

# 💡 Asegura que el agente esté disponible
export SSH_AUTH_SOCK=/ssh-agent
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# 💡 Verifica que ssh funciona
echo "Probando acceso SSH..."
ssh -T git@github.com || echo "SSH no interactivo, esto es esperado"

# 💡 Configura known_hosts para evitar prompts
mkdir -p ~/.ssh
ssh-keyscan github.com >> ~/.ssh/known_hosts

# local.conf won't exist until this step on first execution
source poky/oe-init-build-env

CONFLINE="MACHINE = \"qemuarm64\""

cat conf/local.conf | grep "${CONFLINE}" > /dev/null
local_conf_info=$?

if [ $local_conf_info -ne 0 ];then
	echo "Append ${CONFLINE} in the local.conf file"
	echo ${CONFLINE} >> conf/local.conf
	
else
	echo "${CONFLINE} already exists in the local.conf file"
fi


bitbake-layers show-layers | grep "meta-aesd" > /dev/null
layer_info=$?

if [ $layer_info -ne 0 ];then
	echo "Adding meta-aesd layer"
	bitbake-layers add-layer ../meta-aesd
else
	echo "meta-aesd layer already exists"
fi

set -e
bitbake core-image-aesd
