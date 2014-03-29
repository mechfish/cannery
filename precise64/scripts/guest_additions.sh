#!/bin/bash

set -e

# Install guest additions
mkdir -p /mnt/vg
mount -o loop /home/vagrant/VBoxGuestAdditions*.iso /mnt/vg
cd /mnt/vg
echo "Installing VBox Guest Additions"
sh /mnt/vg/VBoxLinuxAdditions.run || true
echo "Cleaning up guest additions disk."
cd /
umount /mnt/vg
rmdir /mnt/vg


