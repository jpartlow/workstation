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
# @param repository_subdir_mode
#   The permissions to set on any subdirectory structure we create to hold
#   repository checkouts.
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
# @param src_tmux_version
#   Set this to a particular version of tmux to download and install
#   from source if you are stuck on a platform that has old tmux
#   builds in its package manager...like, say, centos7...
class workstation::profile::dev_account_base(
  String $account,
  Array[String] $ssh_public_keys,
  Array[Hash] $repository_data = [],
  String $repository_subdir_mode = '0640',
  Array[Hash] $vim_bundles = [],
  Array[String] $default_packages = [
    'vim',
    'tree',
    'wget',
    'curl',
    'bash-completion',
    # 'tmux' package will be installed if src_tmux_version is not set...
  ],
  Array[String] $additional_packages = [],
  Boolean $manage_dotfiles = true,
  Array[String] $ruby_versions = [],
  Optional[String] $src_tmux_version = undef,
) {
  class { 'workstation::user':
    account => $account,
  }
  contain 'workstation::user'

  if !empty($ruby_versions) {
    class { 'workstation::ruby':
      owner         => $account,
      ruby_versions => $ruby_versions,
    }
    contain workstation::ruby
    Class['Workstation::User'] -> Class['Workstation::Ruby']
  }

  class { 'workstation::ssh':
    user        => $account,
    public_keys => $ssh_public_keys,
  }
  contain 'workstation::ssh'

  # If we aren't building it from source, install the os package.
  $tmux_package = $src_tmux_version =~ Undef ? {
    true  => ['tmux'],
    false => [],
  }
  $_packages = $default_packages + $additional_packages + $tmux_package
  class { 'workstation::packages':
    packages => $_packages,
  }
  contain 'workstation::packages'

  if $src_tmux_version !~ Undef {
    $package = "tmux-${src_tmux_version}.tar.gz"
    $url = "https://github.com/tmux/tmux/releases/download/${src_tmux_version}/${package}"
    $installer_cmds = [
      "cd $(mktemp -d)",
      "curl -fsSL -O ${url}",
      "tar -xf ${package}",
      "cd tmux-${src_tmux_version}",
      "./configure && make",
      "make install",
    ]

    package { "libevent-devel":
      ensure => latest,
    }
    -> exec { "install-tmux-${src_tmux_version}-from-src":
      command => $installer_cmds.join(' && '),
      path    => $facts['path'],
      creates => '/usr/local/bin/tmux',
    }
  }

  contain 'workstation::git'

  class { 'workstation::repositories':
    repository_data => $repository_data,
    user            => $account,
    identity        => 'id_rsa',
    require         => [Class['Workstation::Git']],
    mode            => $repository_subdir_mode,
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
  }
  contain workstation::vim

  class { 'workstation::sudo':
    user => $account,
  }
  contain 'workstation::sudo'

  case $facts['os']['family'] {
    'RedHat': {
       # Ensure .bash_aliases is included in .bashrc on el7
       file_line { 'bashrc aliases':
         ensure => 'present',
         path   => "/home/${account}/.bashrc",
         line   => 'if [ -f ~/.bash_aliases ]; then . ~/.bash_aliases; fi',
         match  => '^if \[ -f ~/.bash_aliases \];',
       }
    }
    'Debian': {
      # If the image has LANG=C.UTF-8, for example, facter complains
      exec { 'ensure sane locale':
        command => 'update-locale LANG=en_US.UTF-8',
        path    => '/usr/bin:/usr/sbin:/usr/bin/local:/bin',
        unless  => "grep -q 'LANG=en_US.UTF-8' /etc/default/locale",
      }
    }
    default: { fail("Unsupported platform ${facts['os']['family']}") }
  }

  # Set resolver for internal dns if host is setup in the
  # engineering-scratchpad project (based on domain name...)
  if ($facts['gce'] !~ Undef and $facts['networking']['domain'] == 'c.engineering-scratchpad.internal') {
    include 'workstation::gcp_engineering_scratchpad'
  }
}
