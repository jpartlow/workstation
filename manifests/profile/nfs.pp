# Class: workstation::profile::nfs
# ================================
#
# Install nfs server and create an empty exports file.
# By itself, this doesn't do much, but lays the base 
# for tasks in meep_tools to add exports lines for
# specific pooler test hosts and then mount src directories
# on the test hosts for development.
#
# Parameters:
# -----------
#
# @param user
#   The user account for file settings related to nfs setup.
class workstation::profile::nfs(
  String $user,
) {

  case $facts['os']['family'] {
    'RedHat': {
      $nfs_server = 'nfs-utils'
    }
    'Debian': {
      $nfs_server = 'nfs-kernel-server'
    }
    default: {
      fail("workstation::profile::nfs only handles Redhat/Debian at the moment, found: ${facts['os']['family']}")
    }
  }

  package { 'nfs_server':
    name   => $nfs_server,
    ensure => present,
  }

  $file_settings = {
    owner => $user,
    group => $user,
    mode  => '0644',
  }

  # (Change group for nfs mounts)
  $account = $user # for template
  file { '/etc/exports':
    ensure  => 'present',
    content => template('workstation/exports.erb'),
    owner   => 'root',
    group   => $user,
    mode    => '0664',
  }
  file { '/s':
    ensure => link,
    target => "/home/${user}/work/src",
    *      => $file_settings,
  }

  service { 'nfs-server':
    ensure  => 'running',
    enable  => true,
    require => Package['nfs_server'],
  }
}
