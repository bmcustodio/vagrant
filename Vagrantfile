# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"

  # Forward some commonly-used ports.
  config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.network "forwarded_port", guest: 12000, host: 12000

  # Configure the machine.
  config.vm.provider "virtualbox" do |vb|
    vb.cpus = 4
    vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
    vb.memory = "16384"
  end
  
  # Provision the machine.
  config.vm.provision "shell", path: "provision.sh", privileged: false
  
  # Configure SSH.
  config.ssh.forward_agent = true
end
