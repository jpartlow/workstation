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
# @param install_dir [String] System wide path rbenv should be installed in.
#   Defaults to '/usr/local/rbenv'.
# @param ruby_versions [Array] List of ruby versions to be installed via
#   ruby-build plugin.  The first ruby in the list will be set as the default
#   global interpreter. (Required)
# @param gems [Array<String>] Simple list of gem names to install.  Does not
#   accept versions yet.
#
class workstation::ruby(
  String $install_dir          = '/usr/local/rbenv',
  Array[String] $ruby_versions = ['2.4.3'],
  Array[String] $gems = [],
) {

  class { 'rbenv':
    install_dir => $install_dir,
  }

  rbenv::plugin { 'sstephenson/ruby-build': }

  $ruby_versions.each |$index, $version| {

    $global = $index ? {
      0       => true,
      default => false,
    }

    rbenv::build { $version:
      global => $global,
    }

    $gems.each |$gem_name| {
      rbenv::gem { "${gem_name} on ${version}":
        gem          => $gem_name,
        ruby_version => $version,
      }
    }
  }
}
