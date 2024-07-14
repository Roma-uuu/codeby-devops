ENV['VAGRANT_SERVER_URL'] = 'http://vagrant.elab.pro'
Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/bionic64"
  config.vm.box_check_update = false

  config.vm.define "server" do |server|
    server.vm.hostname = "server"
    server.vm.network "public_network", ip: "192.168.56.10", bridge: "enp0s3"

    server.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.memory = "512"
    end

    server.vm.provision "shell", path: "provision_server.sh"
  end

  config.vm.define "client" do |client|
    client.vm.hostname = "client"
    client.vm.network "public_network", ip: "192.168.56.11", bridge: "enp0s3"

    client.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.memory = "512"
    end

    # Provisioning script for the client
    client.vm.provision "shell", path: "provision_client.sh"
    client.vm.synced_folder ".", "/vagrant"
    client.ssh.insert_key = false
  end

end
