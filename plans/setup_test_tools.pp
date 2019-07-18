# Setup a workstation to test meep-tools/enterprise_tasks
plan workstation::setup_test_tools(
  TargetSpec $nodes,
) {
  apply_prep($nodes)

  $user = system::env('USER')
  $local_home = system::env('HOME')
  $local_vmfloaty_yml = "${local_home}/.vmfloaty.yml"
  $vmfloaty_yml = "/home/${user}/.vmfloaty.yml"

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

      $bolt_bin = '/opt/puppetlabs/bolt/bin'

      exec { 'add bolt ruby and local gem bins to path':
        command => "echo 'export PATH=${bolt_bin}:\$HOME/.gem/ruby/2.5.0/bin:\$PATH' >> /home/${user}/.bash_profile",
        cwd     => "/home/${user}",
        path    => '/usr/bin:/usr/bin/local:/bin',
        user    => $user,
        unless  => "grep -qE 'export.*bolt' /home/${user}/.bashrc"
      }

      exec { 'install gems':
        command     => "${bolt_bin}/gem install --no-ri --no-rdoc --user-install vmfloaty",
        user        => $user,
        environment => "HOME=/home/${user}",
        path        => "${bolt_bin}:/bin:/usr/bin",
        unless      => "${bolt_bin}/gem list vmfloaty | grep -q 'vmfloaty'",
      }

      contain 'workstation::git'

      class { 'workstation::repositories':
        repository_data => [{
          'path'  => "/home/${user}/work/src",
          'repos' => [
            {
              'source'          => "git@github.com:${user}/enterprise_tasks",
              'upstream'        => 'puppetlabs',
              'checkout_branch' => 'master',
            },
            {
              'source' => "git@github.com:${user}/meep_tools",
            },
          ],
        }],
        user            => $user,
        identity        => 'id_rsa',
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
    }
  }
}
