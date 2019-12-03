# Setup a workstation to test meep-tools/enterprise_tasks
plan workstation::setup_test_tools(
  TargetSpec $nodes,
) {
  apply_prep($nodes)

  $user = system::env('USER')
  $local_home = system::env('HOME')
  $local_vmfloaty_yml = "${local_home}/.vmfloaty.yml"
  $vmfloaty_yml = "/home/${user}/.vmfloaty.yml"
  $repository_data = lookup('workstation::repository_data')
  $vim_bundles = lookup('workstation::vim_bundles')

  get_targets($nodes).each |$n| {

    apply($n) {
      class { 'workstation::user':
        account => $user,
      }
    }

    upload_file($local_vmfloaty_yml, $vmfloaty_yml, $n)

    apply($n) {
      class { 'workstation::ssh':
        user        => $user,
        public_keys => ['id_rsa.pub'],
      }
      contain workstation::ssh

      file { $vmfloaty_yml:
        owner => $user,
        mode  => '0600',
      }

      # el7 specific
      package { 'epel-release':
        ensure => present,
      }

      $packages = [
        'puppet-bolt',
        'vim',
        'tree',
        'wget',
        'curl',
        'ack', # needs epel ^
      ]
      package { $packages:
        ensure  => present,
        require => Package['epel-release'],
      }

      class { 'workstation::ruby':
        owner => $user,
        gems  => [
          'vmfloaty',
        ],
      }

      contain 'workstation::git'

      class { 'workstation::repositories':
        repository_data => $repository_data,
        user            => $user,
        identity        => 'id_rsa',
        require         => [Class['Workstation::Git']],
      }
      contain 'workstation::repositories'

      file { '/s':
        ensure => link,
        target => "/home/${user}/work/src",
      }

      class { 'workstation::bolt':
        account => $user,
      }
      contain 'workstation::bolt'

      class { 'workstation::dotfiles':
        user     => $user,
        identity => 'id_rsa',
      }
      contain workstation::dotfiles

      class { 'workstation::vim':
        user    => $user,
        bundles => $vim_bundles,
        require => Class['Workstation::Repositories'],
      }
      contain workstation::vim

      class { 'workstation::sudo':
        user => $user,
      }
      contain 'workstation::sudo'
    }
  }
}
