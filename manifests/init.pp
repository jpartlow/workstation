# Class: workstation
# ===========================
#
# Controls baseline setup of a development workstation.
#
# Parameters
# ----------
#
# @param account [String] Account name to ensure is created.
# @param repository_data [Array<Hash>] Of repositories to clone. This is
#   passed to the workstation::repositories class.
# @param ssh_public_keys [Array<String>] Of SSH public keys to
#   authorize for access to the $account on the workstation. (see
#   workstation::ssh::public_keys)
# @param vim_bundles [Array<Hash>] Of vim plugin repository info passed to
#   workstation::vim.
# @param gems [Array<String>] List of gems to install by defalt in the versions
#   of ruby being installed.
# @param packages [Array<String>] List of packages to install.
#
# Authors
# -------
#
# Josh Partlow <joshua.partlow@puppetlabs.com>
#
class workstation(
  String $account,
  Array[Hash] $repository_data,
  Array[String] $ssh_public_keys,
  Array[Hash] $vim_bundles = [],
  Array[String] $gems = [],
  Array[String] $packages = [],
  Workstation::Package_repo_struct $package_repositories = [],
){

  class { 'workstation::profile::dev_account_base':
    account             => $account,
    ssh_public_keys     => $ssh_public_keys,
    repository_data     => $repository_data,
    vim_bundles         => $vim_bundles,
    additional_packages => $packages,
  }
  contain 'workstation::profile::dev_account_base'

  class { 'workstation::ruby':
    owner => $account,
    gems  => $gems,
  }
  contain workstation::ruby
  Class['Workstation::User'] -> Class['Workstation::Ruby']

  contain workstation::bin_links

  contain workstation::package_repositories

  contain workstation::known_hosts

  File {
    ensure => directory,
    owner  => $account,
    group  => $account,
  }
  file { "/home/${account}": }
  file { "/home/${account}/bin": }
  file { "/home/${account}/work/tmp": }

  class { 'workstation::frankenbuilder':
    require => Class['workstation::Repositories'],
  }
  contain 'workstation::frankenbuilder'

  contain workstation::bolt

  class { 'workstation::profile::nfs':
    user => $account,
  }
  contain 'workstation::profile::nfs'

  $_pooler_file_args = {
    ensure => 'present',
    owner  => $account,
    group  => $account,
    mode   => '0600',
  }

  # Copying in .fog and .vmfloaty assumes that the account we are generating on the
  # workstation is the same as the account we are running the plan from...
  file { "/home/${account}/.vmfloaty.yml":
    content => file("/home/${account}/.vmfloaty.yml", '/dev/null'),
    *       => $_pooler_file_args,
  }
  file { "/home/${account}/.fog":
    content => file("/home/${account}/.fog", '/dev/null'),
    *       => $_pooler_file_args,
  }

  # Copying over the QE acceptance SSH private key
  # Although in general I'm relying on Agent forwarding,
  # there are some Beaker acceptance tests which assume they can copy this key
  # from the test runner to the SUTs (opsworks for example)
  file { "/home/${account}/.ssh/id_rsa-jenkins":
    content => file("/home/${account}/.ssh/id_rsa-acceptance", '/dev/null'),
    *       => $_pooler_file_args,
  }

  # If the image has LANG=C.UTF-8, for example, facter complains
  exec { 'ensure sane locale':
    command => 'update-locale LANG=en_US.UTF-8',
    path    => '/usr/bin:/usr/sbin:/usr/bin/local:/bin',
    unless  => "grep -q 'LANG=en_US.UTF-8' /etc/default/locale",
  }
}
