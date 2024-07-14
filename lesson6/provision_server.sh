#!/bin/bash

# Update and install necessary packages
apt-get update
apt-get install -y openssh-server

# Check if user 'vagrant' already exists, if not, create it
if id "vagrant" &>/dev/null; then
    echo "User 'vagrant' already exists"
else
    useradd -m -s /bin/bash vagrant
    echo "vagrant:vagrant" | chpasswd
fi

# Ensure the .ssh directory exists and has the correct permissions
mkdir -p /home/vagrant/.ssh
chown -R vagrant:vagrant /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh

# Generate SSH keys if they do not exist
if [ ! -f /home/vagrant/.ssh/id_rsa ]; then
    sudo -u vagrant ssh-keygen -t rsa -b 2048 -f /home/vagrant/.ssh/id_rsa -N ""
    echo "SSH keys generated"
else
    echo "SSH keys already exist"
fi

# Print the public key to the console for debugging purposes
cat /home/vagrant/.ssh/id_rsa.pub

# Add the public key to the authorized_keys file if not already present
grep -q -F "$(cat /home/vagrant/.ssh/id_rsa.pub)" /home/vagrant/.ssh/authorized_keys || cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys

# Copy the private key to shared folder
cp /home/vagrant/.ssh/id_rsa /vagrant/id_rsa
chown vagrant:vagrant /vagrant/id_rsa
echo "SSH private key copied to shared folder"
