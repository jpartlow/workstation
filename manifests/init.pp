# Class: workstation
# ===========================
#
# Controls baseline setup of a development workstation. 
#
# Parameters
# ----------
#
# @param account [String] Account name to ensure is created.
# @param repository_sources [Array<String>] Of repository source urls.
#
# Authors
# -------
#
# Josh Partlow <joshua.partlow@puppetlabs.com>
#
class workstation(
  String $account,
  Array[String] $repository_sources,
){
  include workstation::ruby

  class { workstation::user:
    account => $::workstation::account,
  }
  contain workstation::user

  contain workstation::packages

  contain workstation::git

  contain workstation::known_hosts

  contain workstation::ssh

  File {
    ensure => directory,
    owner  => $account,
    group  => $account,
  }
  file { "/home/${account}": }
  file { "/home/${account}/work": }
  file { "/home/${account}/work/src": }

  workstation::repos { 'main':
    repository_sources => $::workstation::repository_sources,
    require            => Class['Workstation::Git'],
  }

  contain workstation::dotfiles
}
