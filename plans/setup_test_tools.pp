# Setup a workstation to test meep-tools/enterprise_tasks
plan workstation::setup_test_tools(
  TargetSpec $nodes,
) {
  apply_prep($nodes)

  $user = system::env('USER')
  $local_home = system::env('HOME')
  $local_vmfloaty_yml = "${local_home}/.vmfloaty.yml"
  $vmfloaty_yml = "/home/${user}/.vmfloaty.yml"
  $local_control_repo_key = "${local_home}/.ssh/id-control_repo.rsa"
  $control_repo_key = "/home/${user}/.ssh/id-control_repo.rsa"

  get_targets($nodes).each |$n| {

    out::message("Will configure ${n} based on hiera data found for data/nodes/${n.facts['clientcert']}.yaml")

    apply($n) {
      class { 'workstation::user':
        account => $user,
      }
    }

    upload_file($local_vmfloaty_yml, $vmfloaty_yml, $n)
    upload_file($local_control_repo_key, $control_repo_key, $n)

    $results = apply($n, _catch_errors => true) {

      contain 'workstation::profile::dev_account_base'

      file { [$vmfloaty_yml, $control_repo_key]:
        owner => $user,
        mode  => '0600',
      }

      contain 'workstation::package_repositories'

      class { 'workstation::ruby':
        owner => $user,
        gems  => [
          'vmfloaty',
          'tmuxinator',
        ],
      }

      $file_settings = {
        owner => $user,
        group => $user,
        mode  => '0644',
      }

      # (Change group for nfs mounts)
      $account = $user # for template
      file { '/etc/exports':
        ensure  => 'present',
        content => template('workstation/exports.erb'),
        owner   => 'root',
        group   => $user,
        mode    => '0664',
      }
      # (Loosen mode to 0644 for for nfs mounts)
      file { "/home/${user}":
        ensure => directory,
        *      => $file_settings,
      }
      file { "/home/${user}/work":
        ensure => directory,
        *      => $file_settings,
      }
      file { "/home/${user}/work/src":
        ensure => directory,
        *      => $file_settings,
      }
      file { "/home/${user}/work/src/other":
        ensure => directory,
        *      => $file_settings,
      }
      file { '/s':
        ensure => link,
        target => "/home/${user}/work/src",
        *      => $file_settings,
      }

      service { 'nfs-server':
        ensure => 'running',
        enable => true,
      }

      class { 'workstation::bolt':
        account => $user,
      }
      contain 'workstation::bolt'
    }
    workstation::display_apply_results($results.first())
    return $results
  }
}
