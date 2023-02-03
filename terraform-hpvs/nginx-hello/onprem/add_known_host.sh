#!/bin/bash

LIBVIRT_HOST=${1}

echo Adding ${LIBVIRT_HOST} to known_hosts
ssh-keyscan -H ${LIBVIRT_HOST} >> ~/.ssh/known_hosts 2> /dev/null
echo ""
