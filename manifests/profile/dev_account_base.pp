# Class: workstation::profile::dev_account_base
# ====================================
#
# Manages the basics of:
#
# * user account
# * ssh public keys to log into the account
# * git
# * vim and vim bundles if you want them
# * optional git repos to check out
# * any additional packages to install
# * dotfiles (can be skipped)
# * sets up sudo for the account (see {workstation::sudo})
# * adds .bash_aliases to .bashrc
#
# Parameters
# ----------
#
# @param account
#   The user account to manage on the workstation.
# @param ssh_public_keys
#   An array of public key files from your local ~/.ssh
#   to add to the workstation account's authorized_keys.
# @param repository_data
#   Any git repositories you want checked out (see
#   {workstation::repositories} and examples in data/ for
#   the structure needed here.
# @param vim_bundles
#   Any vim bundles to install via pathogen (see
#   {workstation::vim}).
# @param default_pacakges
#   A set of packages I install on dev hosts; replace if unwanted.
# @param additional_packages
#   Additional packages to install.
# @param manage_dotfiles
#   Set this false to not manage a dotfiles repository.
#   (skips {workstation::dotfiles} being included)
class workstation::profile::dev_account_base(
  String $account,
  Array[String] $ssh_public_keys,
  Array[Hash] $repository_data = [],
  Array[Hash] $vim_bundles = [],
  Array[String] $default_packages = [
    'vim',
    'tree',
    'wget',
    'curl',
    'tmux',
    'ack', # (needs epel on el)
    'bash-completion',
  ],
  Array[String] $additional_packages = [],
  Boolean $manage_dotfiles = true,
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

  $_packages = $default_packages + $additional_packages
  class { 'workstation::packages':
    packages => $_packages,
  }
  contain 'workstation::packages'

  contain 'workstation::git'

  class { 'workstation::repositories':
    repository_data => $repository_data,
    user            => $account,
    identity        => 'id_rsa',
    require         => [Class['Workstation::Git']],
  }
  contain 'workstation::repositories'

  if $manage_dotfiles {
    class { 'workstation::dotfiles':
      user     => $account,
      identity => 'id_rsa',
    }
    contain workstation::dotfiles
  }

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
