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
14.04 as the base platform.

Primarily for integration.  Currently this is my way of capturing set up for an
Ubuntu 14.04 dev box, so that I can recreate my dev environment automatically,
either to restore on a new laptop or to do dev work from a vm.  Intention is to
allow me to work with new/clean configuration without risking my current dev
environment's stability for handling day to day work items.  From there can be
expanded to other platforms (notably OSX) for onboarding, or throw away
development testing.

## Setup

Because the purpose of the module is to setup a workstation suitable for
developing Puppet and Puppet Enterprise tools and packaging, from scratch, it
has a bootstrap shell script in vim to handle the initial ruby and puppet
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

* rbenv
* TODO

### Setup Requirements 

The scripts in bin/ provide bootstrapping for installing a puppet-agent into a
new workstation so that the module may then be run.

### Beginning with workstation

The very basic steps needed for a user to get the module up and running. This
can include setup steps, if necessary, or it can be an example of the most
basic use of the module.

## Usage

This section is where you describe how to customize, configure, and do the
fancy stuff with your module here. It's especially helpful if you include usage
examples and code samples for doing things with your module.

## Reference

Here, include a complete list of your module's classes, types, providers,
facts, along with the parameters for each. Users refer to this section (thus
the name "Reference") to find specific details; most users don't read it per
se.

## Limitations

This is where you list OS compatibility, version compatibility, etc. If there
are Known Issues, you might want to include them under their own heading here.

## Development

Since your module is awesome, other users will want to play with it. Let them
know what the ground rules for contributing are.

## Release Notes/Contributors/Etc. **Optional**

If you aren't using changelog, put your release notes here (though you should
consider using changelog). You can also add any additional sections you feel
are necessary or important to include here. Please use the `## ` header.
