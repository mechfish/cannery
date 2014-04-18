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
rm /home/vagrant/VBoxGuestAdditions*.iso

# Emergency symlink to fix https://www.virtualbox.org/ticket/12879
# We can remove this after Virtualbox 4.3.11 is released.
if [ -d /opt/VBoxGuestAdditions-4.3.10 ]; then
    ln -s /opt/VBoxGuestAdditions-4.3.10/lib/VBoxGuestAdditions /usr/lib/VBoxGuestAdditions
fi
