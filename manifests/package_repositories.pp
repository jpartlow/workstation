# Class: workstation::package_repositories
#
# Handles setting up additional Apt repositories to install packages from.
class workstation::package_repositories(
  Workstation::Package_repo_struct $repositories = $::workstation::package_repositories,
){
  apt::key { 'puppetlabs':
    id     => '6F6B15509CF8E59E6E469F327F438280EF8D349F',
    server => 'pgp.mit.edu',
  }

  $repositories.each |$repo| {
    $repo_package_url = $repo['repo_package_url']
    $repo_package = split($repo_package_url, '/')[-1]
    $packages = $repo['packages']
    exec { "install ${repo_package} repository package":
      command => "wget ${repo_package_url} && dpkg -i ${repo_package} && apt-get update",
      path    => '/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/bin',
      unless  => "dpkg -l ${repo_package} | grep -E '^ii'",
    }

    package { $packages:
      ensure => latest
    }
  }
}
