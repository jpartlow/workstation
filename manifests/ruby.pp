# Class: workstation::ruby
# ========================
#
# Handles installation of ruby using the rbenv environment abstraction to allow
# for multiple isolated ruby builds and gem environments.
#
# In this class, rbenv is installed systemwide.
#
# Parameters
# ----------
#
# @param owner [String] The system account that should own the ruby installation. Required.
# @param group [String] The system account that should be the group for the
#   ruby installation. Defaults to $owner
# @param install_dir [String] The path rbenv should be installed in.
#   Defaults to '/home/${owner}/.rbenv'.
# @param ruby_versions [Array] List of ruby versions to be installed via
#   ruby-build plugin.  The first ruby in the list will be set as the default
#   global interpreter. (Required)
# @param gems [Array<String>] Simple list of gem names to install.  Does not
#   accept versions yet.
#
class workstation::ruby(
  String $owner,
  String $group                = $owner,
  String $install_dir          = "/home/${owner}/.rbenv",
  Boolean $manage_profile      = $owner == 'root',
  Array[String] $ruby_versions = ['2.5.1'],
  Array[String] $gems = [],
) {

  $os_major = split($facts['os']['release']['major'], '\.')[0]
  $_manage_deps = Integer($os_major) < 18

  class { 'rbenv':
    owner          => $owner,
    group          => $group,
    install_dir    => $install_dir,
    manage_profile => $manage_profile,
    manage_deps    => $_manage_deps,
  }

  if !$manage_profile {
    $bashrc_snippet = @(EOS/$)
      export PATH="\$HOME/.rbenv/bin:\$PATH"
      eval "\$(rbenv init -)"
      | EOS

    exec { 'add rbenv to .bashrc':
      command => "echo '${bashrc_snippet}' >> /home/${owner}/.bashrc",
      cwd     => "/home/${owner}",
      path    => '/usr/bin:/usr/bin/local:/bin',
      user    => $owner,
      unless  => "grep -qE 'rbenv init -' /home/${owner}/.bashrc",
    }
  }

  class { 'workstation::ruby::dependencies':
    ubuntu_18 => Integer($os_major) >= 18,
  }
  contain 'workstation::ruby::dependencies'

  rbenv::plugin { 'rbenv/ruby-build': }

  class { 'workstation::ruby::versions':
    ruby_versions => $ruby_versions,
    gems          => $gems,
    require       => [Rbenv::Plugin['rbenv/ruby-build'],Class['Workstation::Ruby::Dependencies']],
  }
  contain 'workstation::ruby::versions'

  workstation::set_owner_group { "/home/${owner}/.rbenv":
    owner   => $owner,
    group   => $group,
    require => Class['Workstation::Ruby::Versions'],
  }
}
