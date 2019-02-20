# workstation

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with workstation](#setup)
    * [What workstation affects](#what-workstation-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with workstation](#beginning-with-workstation)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module will bootstrap a fresh development vm or laptop into a known state
suitable for PE integration development.  Currently only working with Ubuntu
18.04 as the base platform.

Primarily for integration.  Currently this is my way of capturing set up for an
Ubuntu 18.04 dev box, so that I can recreate my dev environment automatically,
either to restore on a new laptop or to do dev work from a vm.  Intention is to
allow me to work with new/clean configuration without risking my current dev
environment's stability for handling day to day work items.  From there can be
expanded to other platforms (notably OSX) for onboarding, or throw away
development testing.

## Setup

Because the purpose of the module is to setup a workstation suitable for
developing Puppet and Puppet Enterprise tools and packaging, from scratch, it
has a bootstrap shell script in bin to handle the initial ruby and puppet
dependencies by installing the standalone puppet-agent (which includes its own
ruby).  Because this is installed into /opt, it is isolated from the rest of
the system.  The script can than use the puppet module tool to install this
module (and it's dependencies) to a temporary path and then use puppet to apply
the classes to set up rbenv, dev tools, vm tools, development repositories, the
dev's own keys, dotfiles etc.

## Vagrantfile

Provides a local vm for testing without destroying the workstation you have
this repository checked out in.

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

### Setup Requirements

The scripts in bin/ provide bootstrapping for installing a puppet-agent into a
new workstation so that the module may then be run.

### Beginning with workstation

You may manually clone pl-dev onto a host and run bin/install.sh, but you will likely need to have already prepared the host with your ssh keys.

If you are preparing a vm or host with sshd that you have network access to, and you have an account with root or sudo root privileges and ssh keys, then you can just invoke this to install puppet-agent 1.4.1 and apply the workstation manifest on the given host:

``` sh
$ bin/install.sh -a 1.4.1 -h <user>@<host.vm> [-i ssh-keyfile]
```

## Usage

You can customize the modules actions by editing a version of hieradata/common.yaml to change any parameters.  This file can be supplied to bin/install.sh by using the -c flag.

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

## Limitations

Currently only written and tested for an Ubuntu host (18.04 specifically).

## Development

joshua.partlow@puppetlabs.com
