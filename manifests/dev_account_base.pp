class workstation::dev_account_base(
  String $account,
  Array[String] $ssh_public_keys,
  Array[Hash] $repository_data = [],
  Array[Hash] $vim_bundles = [],
  Array[String] $additional_packages = [],
) {
  class { 'workstation::user':
    account => $account,
  }
  contain 'workstation::user'

  class { 'workstation::ssh':
    user        => $account,
    public_keys => $ssh_public_keys,
  }
  contain 'workstation::ssh'

  # el7 specific
  package { 'epel-release':
    ensure => present,
  }

  $packages = [
    'vim',
    'tree',
    'wget',
    'curl',
    'tmux',
    'ack', # needs epel ^
    'bash-completion',
  ]
  $_packages = $packages + $additional_packages
  package { $_packages:
    ensure  => present,
    require => Package['epel-release'],
  }

  contain 'workstation::git'

  class { 'workstation::repositories':
    repository_data => $repository_data,
    user            => $account,
    identity        => 'id_rsa',
    require         => [Class['Workstation::Git']],
  }
  contain 'workstation::repositories'

  class { 'workstation::dotfiles':
    user     => $account,
    identity => 'id_rsa',
  }
  contain workstation::dotfiles

  class { 'workstation::vim':
    user    => $account,
    bundles => $vim_bundles,
    require => Class['Workstation::Repositories'],
  }
  contain workstation::vim

  class { 'workstation::sudo':
    user => $account,
  }
  contain 'workstation::sudo'

  # Ensure .bash_aliases is included in .bashrc on el7
  file_line { 'bashrc aliases':
    ensure => 'present',
    path   => "/home/${account}/.bashrc",
    line   => 'if [ -f ~/.bash_aliases ]; then . ~/.bash_aliases; fi',
    match  => '^if \[ -f ~/.bash_aliases \];',
  }
}
