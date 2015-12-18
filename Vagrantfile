# -*- mode: ruby -*-
# vi: set ft=ruby :

pl_dev_remote_origin_url = `git config remote.origin.url`

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # So that local keys can be used to clone repositories from Github
  config.ssh.forward_agent = true

  config.vm.define "dev-test" do |dev|
    dev.vm.hostname = "dev-test"
    dev.vm.box = "puppetlabs/ubuntu-14.04-64-nocm"
    dev.vm.provider "virtualbox" do |v|
      v.memory = 1024 * 8
      v.cpus = 4
    end

    dev.vm.provision "shell",
      :name => "install-git",
      :inline => "
        apt-get update
        apt-get install -y git
      "
    # Without this step, the git clone fails because the github.com ssh key is unknown
    dev.vm.provision "shell",
      :name => "modify-ssh",
      :inline => "
        mkdir ~/.ssh
        chmod 700 ~/.ssh
        echo 'Host github.com'
        echo '  StrictHostKeyChecking=no' >> ~/.ssh/config
      "
    dev.vm.provision "shell",
      :name => "clone-pl-dev",
      :inline => "
        [ ! -e pl-dev ] && git clone #{pl_dev_remote_origin_url}
      "
  end
end
