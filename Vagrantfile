# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # So that local keys can be used to clone repositories from Github
  config.ssh.forward_agent = true
  config.vm.define "dev-test" do |dev|
    dev.vm.hostname = "dev-test"
    dev.vm.box = "ubuntu/bionic64"
    dev.vm.provider "virtualbox" do |v|
      v.memory = 1024 * 4
      v.cpus = 2
    end
    dev.vm.network "private_network", ip: "172.16.0.2"
  end
end
