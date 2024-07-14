#!/bin/bash

# Update and install necessary packages
apt-get update
apt-get install -y openssh-client

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

# Copy the SSH private key from the shared folder if it exists
if [ -f /vagrant/id_rsa ]; then
    cp /vagrant/id_rsa /home/vagrant/.ssh/id_rsa
    chown vagrant:vagrant /home/vagrant/.ssh/id_rsa
    chmod 600 /home/vagrant/.ssh/id_rsa
    echo "SSH private key copied to /home/vagrant/.ssh/id_rsa"
else
    echo "SSH private key not found in /vagrant/id_rsa"
fi
