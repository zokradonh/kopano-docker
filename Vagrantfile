# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  if !Vagrant.has_plugin?("vagrant-docker-compose")
    print "  WARN: Missing plugin 'vagrant-docker-compose'.\n"
    print "  Use 'vagrant plugin install vagrant-docker-compose' to install.\n"
  end

  compose_env = Hash.new
  if File.file?(".env")
    array = File.read(".env").split("\n")
    array.each do |e|
      unless e.start_with?("#")
        var = e.split("=")
        compose_env[var[0]] = var[1]
      end
    end
  end

  config.vm.provision :docker
  config.vm.provision :docker_compose,
    project_name: "docker-vagrant",
    yml: "/vagrant/docker-compose.yml",
    env: compose_env,
    run: "always"
end