# Class: workstation::frankenbuilder
# ==================================
#
# Setup up configuration for frankenbuilder instances.
# Stamps out a local .frankenbuilder config file for each
# frankenbuilder checkout I want configured to work with 
# a matching pe_acceptance_tests checkout.
#
# Parameters
# ----------
# @param user [String] User account being configured.
# @param path [String] Path to the directory containing all of the
#   frankenbuilder/pe_acceptance_tests checkout.
# @param suffixes Array[String] Array of suffixes that pair each $path/frankenbuilder_$suffix
#   repo with a $path/pe_acceptance_tests_$suffix repo. Empty array by default, so does nothing.
class workstation::frankenbuilder(
  String $user = $::workstation::user::account,
  String $path = 'work/src/alternates',
  Array[String] $suffixes = [],
) {
  $homedir = "/home/${user}"

  $file_args = {
    owner => $user,
    group => $user,
    mode  => '0644',
  }

  file { "${homedir}/pe_builds":
    ensure => 'directory',
    *      => $file_args,
  }

  $suffixes.each |$i| {
    $frankenmodule_tmp=$i
    $frankenbuilder_path="${homedir}/${path}/frankenbuilder_${i}"
    $pe_acceptance_test_path="${homedir}/${path}/pe_acceptance_tests_${i}"
    file { "${frankenbuilder_path}/.frankenbuilder":
      ensure  => 'present',
      content => template('workstation/frankenbuilder.erb'),
      *       => $file_args
    }
  }
}
