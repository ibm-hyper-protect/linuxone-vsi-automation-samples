#!/bin/bash
set -eu

apt-get update 
apt-get install -y openssl

echo "unencrypted message"
echo "encrypted message" | /bin/bash /var/logging/bin/encrypt-basic.sh /var/logging/logging.pub
