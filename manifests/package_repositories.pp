# Class: workstation::package_repositories
#
# Handles setting up additional Apt repositories to install packages from.
class workstation::package_repositories(
  Workstation::Package_repo_struct $repositories = $::workstation::package_repositories,
){
  if $facts['os']['family'] == 'Debian' {
    apt::key { 'puppetlabs':
      id     => '6F6B15509CF8E59E6E469F327F438280EF8D349F',
      server => 'pgp.mit.edu',
    }
  }

  # Backup to what count to clip 'some-platform.pkg' from the file name?
  $negative_package_name_index = $facts['os']['family'] ? {
    'Debian' => -3,
    'RedHat' => -5,
  }

  $repositories.each |$repo| {
    # Ex: https://yum.puppet.com/puppet-tools-release-el-6.noarch.rpm
    # or
    # Ex: https://apt.puppet.com/puppet-tools-release-bionic.deb
    $repo_package_url = $repo['repo_package_url']

    # Ex: puppet-tools-release-el-6.noarch.rpm
    # or
    # EX: puppet-tools-release-bionic.deb
    $repo_package_file = split($repo_package_url, '/')[-1]

    # EX: puppet-tools-release
    $repo_package_name = join(split($repo_package_file, '[.-]')[0,$negative_package_name_index], '-')

    case $facts['os']['family'] {
      'RedHat': {
        exec { "install ${repo_package_name} repository package":
          command => "rpm -Uvh ${repo_package_url}",
          path    => '/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/bin',
          unless  => "rpm -q ${repo_package_name}",
        }
      }

      'Debian': {
        exec { "install ${repo_package_name} repository package":
          command => "wget ${repo_package_url} && dpkg -i ${repo_package_file} && apt-get update",
          path    => '/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/bin',
          unless  => "dpkg -l ${repo_package_name} | grep -E '^ii'",
        }
      }

      default: {
        fail("Can't handle repository packages for ${facts['os']['family']}")
      }
    }

    package { $repo['packages']:
      ensure => latest
    }
  }
}
