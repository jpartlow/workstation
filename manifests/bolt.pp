# Class: workstation::bolt
#
# Manages configuration of the Bolt installation on the host.
#
# @param account [String] Account we are building.
class workstation::bolt(
  String $account = $::workstation::account,
){
  $file_args = {
    owner => $account,
    group => $account,
    mode   => '0664',
  }

  $puppetlabs_dir = "/home/${account}/.puppetlabs"
  $bolt_modulepath = "${puppetlabs_dir}/bolt-code/modules"
  $bolt_dirs = [
    $puppetlabs_dir,
    "${puppetlabs_dir}/bolt",
    "${puppetlabs_dir}/bolt-code",
    $bolt_modulepath,
  ]
  file { $bolt_dirs:
    ensure => directory,
    *      => $file_args,
  }

  $bolt_modules = [
    'meep_tools',
    'enterprise_tasks',
  ].each |$module| {
    file { "${bolt_modulepath}/${module}":
      ensure => 'link',
      target => "/s/${module}",
    }
  }

  file { "${puppetlabs_dir}/bolt/bolt.yaml":
    ensure  => present,
    content => template('workstation/bolt.erb'),
    *       => $file_args
  }
}
