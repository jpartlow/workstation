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
  Boolean $manage_profile      = false,
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

  class { 'workstation::ruby::dependencies':
    ubuntu_18 => Integer($os_major) >= 18,
  }
  contain 'workstation::ruby::dependencies'

  rbenv::plugin { 'rbenv/ruby-build': }

  $ruby_versions.each |$index, $version| {

    $global = $index ? {
      0       => true,
      default => false,
    }

    rbenv::build { $version:
      global  => $global,
      require => Class['Workstation::Ruby::Dependencies'],
    }

    $gems.each |$gem_name| {
      rbenv::gem { "${gem_name} on ${version}":
        gem          => $gem_name,
        ruby_version => $version,
      }
    }
  }
}
