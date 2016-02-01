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
#
class workstation::ruby(
  String $install_dir 	       = '/usr/local/rbenv',
  Array[String] $ruby_versions = ['2.3.0', '2.2.4', '1.9.3-p551', '1.8.7-p335']
) {

  class { 'rbenv':
    install_dir => $install_dir,
  }

  rbenv::plugin { 'sstephenson/ruby-build': }

  $ruby_versions.each |$index, $version| {

    $global = $index ? {
      1       => true,
      default => false,
    }

    rbenv::build { $version:
      global => $global,
    }
  }
}
