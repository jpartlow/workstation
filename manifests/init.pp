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
# @param ssh_public_keys [Array<Array<String>>] Of SSH public keys to
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
  Array[Array[String]] $ssh_public_keys,
  Array[Hash] $vim_bundles = [],
  Array[String] $gems = [],
  Array[String] $packages = [],
  Workstation::Package_repo_struct $package_repositories = [],
){
  class { 'workstation::user':
    account => $::workstation::account,
  }
  contain workstation::user

  class { 'workstation::ruby':
    owner => $account,
    gems  => $gems,
  }
  contain workstation::ruby
  Class['Workstation::User'] -> Class['Workstation::Ruby']

  contain workstation::packages

  contain workstation::package_repositories

  contain workstation::git

  contain workstation::known_hosts

  class { 'workstation::ssh':
    public_keys => $ssh_public_keys,
  }
  contain workstation::ssh

  File {
    ensure => directory,
    owner  => $account,
    group  => $account,
  }
  file { "/home/${account}": }
  file { "/home/${account}/bin": }
  file { "/home/${account}/work": }
  file { "/home/${account}/work/src": }
  file { "/home/${account}/work/src/pe-modules": }
  file { "/home/${account}/work/src/puppetlabs": }
  file { "/home/${account}/work/src/alternates": }
  file { "/home/${account}/work/src/other": }
  file { "/home/${account}/work/tmp": }

  class { 'workstation::repositories':
    repository_data => $::workstation::repository_data,
    user            => $::workstation::user::account,
    identity        => 'id_rsa',
    require         => [
      Class['Workstation::Git'],
      File["/home/${account}/work/src/pe-modules"],
      File["/home/${account}/work/src/puppetlabs"],
      File["/home/${account}/work/src/alternates"],
    ],
  }
  contain workstation::repositories

  class { 'workstation::dotfiles':
    user     => $::workstation::user::account,
    identity => 'id_rsa',
  }
  contain workstation::dotfiles

  class { 'workstation::vim':
    user    => $::workstation::user::account,
    bundles => $vim_bundles,
    require => Class['Workstation::Repositories'],
  }
  contain workstation::vim

  contain 'workstation::sudo'

  class { 'workstation::frankenbuilder':
    require => Class['workstation::Repositories'],
  }
  contain 'workstation::frankenbuilder'

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
  file { '/s':
    ensure => 'link',
    target => "/home/${account}/work/src",
  }

  # Prep an exports file for nfs mounts from test hosts
  file { '/etc/exports':
    ensure  => 'present',
    content => template('workstation/exports.erb'),
    owner   => 'root',
    group   => $account,
    mode    => '0664',
  }

  # If the image has LANG=C.UTF-8, for example, facter complains
  exec { 'ensure sane locale':
    command => 'update-locale LANG=en_US.UTF-8',
    path    => '/usr/bin:/usr/sbin:/usr/bin/local:/bin',
    unless  => "grep -q 'LANG=en_US.UTF-8' /etc/default/locale",
  }
}
