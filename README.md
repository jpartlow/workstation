# workstation

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with workstation](#setup)
    * [What workstation affects](#what-workstation-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with workstation](#beginning-with-workstation)
1. [Usage](#usage)
    * [Manage](#manage)
    * [Profile Classes](#profile-classes)
        * [Configuring workstation](#configuring-workstation)
        * [Configuring workstation::profile::dev_account_base](#configuring-dev_account_base)
        * [Configuring workstation::k8s](#configuring-k8s)
1. [Reference - Short list of class/defined type references](#reference)
1. [Testing](#testing)
    * [Vagrantfile - A test host](#vagrantfile)
    * [Specs](#specs)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module will bootstrap a fresh development vm or laptop into a known state
suitable for PE management development. The base workstation classes should be
useable for Ubuntu 18.04 or Centos 7. The workstation::k8s classes are specific
to el7 atm.

Currently this is my way of capturing set up for an Ubuntu 18.04 dev box, so
that I can recreate my dev environment automatically, either to restore on a
new laptop or to do dev work from a vm. Intention is to allow me to work with
new/clean configuration without risking my current dev environment's stability
for handling day to day work items. From there it could be expanded to other
platforms (perhaps OSX) for onboarding, or throw away development testing.

The module makes use of Bolt to manage the workstation. The
workstation::manage plan (in plans/manage.pp) uses apply_prep to get
puppet-agent installed on the node, and then can apply whatever class list
it's given via hiera and the 'workstation::profiles' array to manage the node(s).

Configuration of the module is handled by Hiera, through data/nodes matching
the target's clientcert (see below for details).

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

It is intended to be used to configure a separate Ubuntu 18.04 or Centos7 host
(vm) that you have an account on which you can ssh too, and which you can
escalate to root via sudo.

In order for the vcsrepo module to be able to clone repositories from
git\@github.com/foo/bar sources (via ssh), you will need to enable SSH
ForwardAgent in your ~/.ssh/config for the host. (It's assumed this is a
freshly minted vm, without your ssh keys, and that even if your private keys
were present, a password would be required to use them...)

The required modules for running workstation are listed in the Boltdir/Puppetfile.

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

### Manage

The manage plan is configured with Hiera data as configured by the module's
[hiera.yaml](hiera.yaml).  There is a sample file in the data/ directory, but
that's mostly empty. My workstation configuration under data/jpartlow.yaml
should provide guidelines for what you need.

The module expects to find a yaml file (or symlink) in data/nodes/ matching the
Puppet certname of the node to be configured. This file should have the
necessary workstation parameters set. The hieararchy is based on hiera.yaml.

Create a data file and symlink data/nodes/{certname}.yaml to it. So for a
hypothetical vm that has the Puppet certname 'work1.platform9.puppet.net',
there should be a file or link in data/nodes/work1.platform9.puppet.net.yaml
with the necessary parameters.

The manage plan applies classes to the host based on the list of classes given
in the 'workstation::profiles' array. This parameter must be set in hiera or
nothing happens. The plan applies each class individually. This has the benefit
of ignoring dependencies/conflicts across classes, and the drawback of ignoring
dependencies/conflicts across classes...so you need to keep in mind that class
2 could overwrite changes from class 1, for example...and that 1 needs to
setup whatever 2 might need to proceed...).

Once data/common.yaml is pointing to the set of parameters you want, and you've
added at least one class to 'workstation::profiles' run the workstation::manage
plan:

``` sh
bolt plan run workstation::manage -n <your-host> --no-host-key-check --run-as root
```

That should be it, except for whatever didn't work.

### Profile Classes

#### Configuring [workstation](manifests/init.pp)

*Note*: The workstation class is very specific to my environment preferences.
It expects to find a {user}/dotfiles repository in Github, for example, and local
config/token files for things like vmfloaty and fog. It installs ruby via rbenv,
sets up repos like frankenbuilder, preps sudo and nfs and similar pecularities
I use working on PE. As such it's probably not useful for general workstation
setup without some additional work. If you want some base account setup, see
workstation::profile::dev_account_base below.

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

It should work on both Ubuntu/Centos (tested on ubuntu 18.04, centos7).

#### Configuring [dev_account_base](manifests/profile/dev_account_base.pp)

This will perform a basic dev setup on an el host without any of my PE centric
bits the workstation class has (such as frankenbuilder or nfs).

It is handy coupled with workstation::k8s if you want to manage checkout of
[holodeck-manifests] at the same time, for example.

Unless you are using a similar dotfiles scheme as I am ([jpartlow/dotfiles]),
you will probably want workstation::profile::dev_account_base::manage_dotfiles set to
false.

#### Configuring [k8s](manifests/k8s.pp)

This class is intended to be generally useful for prepping the k8s environment
required by [holodeck-manifests] on an el7 host. It was tested on a [platform9]
centos_7_x86_64 xl host (8GB memory is insufficient).

See the class for the details of what it manages.

[data/jpartlow-k8s.yaml](data/jpartlow-k8s.yaml)
is a hiera config I'm using.

The required workstation::profiles is just 'workstation::k8s'; the
dev_account_base class is setting up my dev environment in addition to k8s.

The required k8s parameters are:

* workstation::k8s::dev_user - the user account to install some tools and copy license files to
* workstation::k8s::replicated_license_file - local path to your replicated license yaml
* workstation::k8s::cd4pe_license_file - local path to your cd4pe license json

The latter two files are used by [holodeck-manifests] when running test targets.

### Configuring a meep_tools test host

This plan is a little more minimal than applying 'workstation' and sets up a vm
with ruby and bolt for pe-installer tooling work. Sample config is
data/test-tools.yaml.  Again, a data/nodes/{certname}.yaml must exist for the
node you are configuring with whatever set of parameters you intend to pass on
to the apply block in the workstation::setup_test_tools plan...

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
* workstation::k8s - kubernetes configuration for [holodeck-manifests] (el7)
* workstation::dev_account_base - a slimmer dev set up (no ruby, lein, frakenbuilder, nfs) (el7)

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

Currently only written and tested for an Ubuntu host (18.04 specifically) and Centos 7.
(Not all the main profile classes work for both platforms atm, see above).

## Development

joshua.partlow@puppetlabs.com

[holodeck-manifests]: https://github.com/puppetlabs/holodeck-manifests
[platform9]: https://puppet.platform9.net
[jpartlow/dotfiles]: https://github.com/jpartlow/dotfiles
