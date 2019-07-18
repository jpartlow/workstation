# workstation

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with workstation](#setup)
    * [What workstation affects](#what-workstation-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with workstation](#beginning-with-workstation)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - Short list of class/defined type references](#reference)
1. [Testing](#testing)
    * [Vagrantfile - A test host](#vagrantfile)
    * [Specs](#specs)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module will bootstrap a fresh development vm or laptop into a known state
suitable for PE management development.  Currently only working with Ubuntu
18.04 as the base platform.

Currently this is my way of capturing set up for an Ubuntu 18.04 dev box, so
that I can recreate my dev environment automatically, either to restore on a
new laptop or to do dev work from a vm.  Intention is to allow me to work with
new/clean configuration without risking my current dev environment's stability
for handling day to day work items.  From there can be expanded to other
platforms (notably OSX) for onboarding, or throw away development testing.

The module makes use of Bolt to manage the workstation.  The
workstation::manage plan (in plans/manage.pp) uses apply_prep to get
puppet-agent installed on the node, and then can apply 'include workstation'
building the catalog locally (after a `bolt puppetfile install` has installed
dependencies), and then shipping it to remote workstation and applying it
there.

Configuration of the module is handled by Hiera, through data/common.yaml (see
below for details)

## Setup

Because the purpose of the module is to setup a workstation suitable for
developing Puppet and Puppet Enterprise tools and packaging, from scratch, it
uses Bolt for bootstraping initial ruby and puppet dependencies by installing
the puppet-agent (which includes its own ruby), and for applying the manifests
on the remote hosts to configure to the desired state.

### What workstation affects

* user account
* homedir
* jpartlow/dotfiles (base $HOME config from a repo checkout)
* $HOME workstation structure (directories)
* rbenv/ruby-build
* packages
* git repositories, cloning, remotes, upstream link, branch checkout
* ssh public keys
* vim plugins/config
* gems

### Requirements

This module requires puppet-bolt to have been installed in order for it to be used.

It is intended to be used to configure a separate Ubuntu 18.04 host (vm) that
you have an account on which you can ssh too, and which you can escalate to
root via sudo.

In order for the vcsrepo module to be able to clone repositories from
git@github.com/foo/bar sources (via ssh), you will need to enable SSH
ForwardAgent in your ~/.ssh/config for the host. (It's assumed this is a
freshly minted vm, without your ssh keys, and that even if your private keys
were present, a password would be required to use them...)

The required modules for running workstation are listed in in the Boltdir/Puppetfile.

## Usage

### Dependencies

Ensure that the module's dependencies are installed b by running bolt puppetfile:

```sh
bolt puppetfile install
```

### Configuring SSH

Once you have a vm to configure, ensure that you can ssh to it, and that once
there, you can `ssh git@github.com` (if you are setting up repositories via ssh).

So, for a hypothetical vm 'work-test' at 192.168.0.2, reachabale as 'ubuntu'
with the key 'vm.ssh.key.pem', a ~/.ssh/config entry such as:

```
Host 192.168.0.2 work-test
User ubuntu
IdentityFile ~/.ssh/vm.ssh.key.pem'
ForwardAgent true
```

Should allow you to `ssh work-test` and from there to `ssh git@github.com`
assuming you're running an ssh-agent locally with the correct keys for Github.

### Configuring workstation

The module is configured with Hiera data. There is a sample file in the data/
directory, but that's mostly empty. The test data/vagrant.yaml or my
workstation configuration under data/jpartlow.yaml should provide what you
need.

The module expects to find a data/common.yaml (based on hiera.yaml's
configuration), with the necessary workstation parameters set.

Create a data file and symlink data/common.yaml to it.

The principle parameters that must be set are:

* workstation::account - the account name to setup on the workstation vm
* workstation::repository_data - the data structure contains the layout and
  sources for repositories to install -- see data/vagrant.yaml for a simple
  example, data/jpartlow.yaml for a more complete one and class
  workstation::repositories and the defined types it uses for the details.
* workstation::packages - a simple list of packages to install
* workstation::vim_bundles - if you want to source vim Pathogen plugins (see workstation::vim)
* workstation::gems - simple list of gems to be installed
* workstation::ruby::ruby_versions - simple list of ruby versions to be installed via rbenv
* workstation::ssh_public_keys - to add public keys to the account's ~/.ssh/authorized_keys (see workstation::ssh)

Once data/common.yaml is pointing to the set of parameters you want, run the
workstation::manage plan:

``` sh
bolt plan run workstation::manage -n <your-host> --no-host-key-check --run-as root
```

That should be it, except for whatever didn't work.

### Configuring a meep_tools test host

This plan sets up a vm so that you can run meep_tools/enterprise_tasks plans. It should probably be simplified.

(Below was tested on a centos-7 vm, which required the --tty flag)

```sh
bolt plan run workstation::setup_test_tools -n <your-host> --no-host-key-check --run-as-root --tty
```
## Reference

* workstation
* workstation::ruby - installs a ruby via rbenv
* workstation::user - sets up up a user account
* workstation::packages - installs system packages
* workstation::package_repositories - configures a particular package repository
  and installs packages that it provides
* workstation::git  - ensures git is installed and configured
* workstation::known_hosts - adds ssh keys to known_hosts config (Github)
* workstation::ssh - adds authorized public keys and .ssh/config settings
* workstation::repositories - clones and configures a set of git repositories
* workstation::dotfiles - sets up an isolated dotfiles repository in $HOME
* workstation::vim - configures vim and installs plugins
* workstation::sudo - adds user to sudoers
* workstation::lein - installs leiningen
* workstation::frankenbuilder - some customization for frankenbuilder work clones

## Testing

### Vagrantfile

Provides a local vm for testing without destroying the workstation you have
this repository checked out in. It sets up a private network (host only) and
the test node should be accessible at 172.16.0.2

```sh
vagrant up
```

You must set up agent forwarding. The following config added to ~/.ssh/config
should allow you to `ssh vagrant@dev-test` (assuming that the workstation repo
was located in the root of your $HOME, otherwise you'll need to adjust
IdentityFile).

```
# Vagrant test host for workstation module
Host 172.16.0.2
ForwardAgent yes
UserKnownHostsFile /dev/null
StrictHostKeyChecking no
PasswordAuthentication no
IdentityFile ~/workstation/.vagrant/machines/dev-test/virtualbox/private_key
```

Then you can select which data file to use. For testing, you can just use the data/vagrant.yaml:

```sh
pushd data/; ln -s vagrant.yaml common.yaml; popd
```

Then run bolt to manage the vagrant host.

```sh
bolt plan run workstation::manage -n 172.16.0.2 -u vagrant --no-host-key-check --run-as root
```

### Specs

The module has a suite of rspec-puppet tests for the various classes and defines.

To run those, it should be sufficient to:

```sh
bundle install
bundle exe rake spec
```

## Limitations

Currently only written and tested for an Ubuntu host (18.04 specifically).

## Development

joshua.partlow@puppetlabs.com
