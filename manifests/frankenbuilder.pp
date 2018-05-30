# Class: workstation::frankenbuilder
# ==================================
#
# Setup up configuration for frankenbuilder instances.
class workstation::frankenbuilder(
  String $user = $::workstation::user::account,
  String $path = 'work/src',
  String $alternates = 'work/src/alternates',
  Integer $count = 5,
) {
  $homedir = "/home/$user"

  $file_args = {
    owner => $user,
    group => $user,
    mode  => '0644',
  }

  file { "${homedir}/pe_builds":
    ensure => 'directory',
    *      => $file_args,
  }

  $frankenmodule_tmp='0'
  $frankenbuilder_path="${homedir}/${path}/frankenbuilder"
  $pe_acceptance_test_path="${homedir}/${path}/pe_acceptance_tests"
  file { "${frankenbuilder_path}/.frankenbuilder":
    ensure => 'present',
    content => template('workstation/frankenbuilder.erb'),
    *       => $file_args
  }

  [2,3,4,5].each |$i| {
    $frankenmodule_tmp=$i
    $frankenbuilder_path="${homedir}/${alternates}/frankenbuilder_${i}"
    $pe_acceptance_test_path="${homedir}/${alternates}/pe_acceptance_tests_${i}"
    file { "${frankenbuilder_path}/.frankenbuilder":
    ensure => 'present',
      content => template('workstation/frankenbuilder.erb'),
      *       => $file_args
    }
  }
}
