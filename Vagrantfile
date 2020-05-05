# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  if !Vagrant.has_plugin?("vagrant-docker-compose")
    print "  WARN: Missing plugin 'vagrant-docker-compose'.\n"
    print "  Use 'vagrant plugin install vagrant-docker-compose' to install.\n"
  end

  config.vm.box = "hashicorp/bionic64"

  config.vm.provider "virtualbox" do |v|
    v.memory = 4096
    v.cpus = 2
  end

  config.vm.network "private_network", ip: "10.16.73.20"

  config.vm.provision :docker
  config.vm.provision :docker_compose

  config.vm.provision :shell, :path => "./.ci/setup-tools.sh"

  config.vm.provision "app",
    type: "shell",
    keep_color: true,
    privileged: false,
    run: "always",
    inline: <<-SCRIPT
      cd /vagrant
      docker-compose up --detach
    SCRIPT
end
