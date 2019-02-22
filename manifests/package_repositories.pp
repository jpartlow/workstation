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
    # puppet6-release-bionic.deb
    $repo_package_deb = split($repo_package_url, '/')[-1]
    # puppet6-release
    $repo_package_name = join(split($repo_package_deb, '-')[0,2], '-')
    $packages = $repo['packages']
    exec { "install ${repo_package_name} repository package":
      command => "wget ${repo_package_url} && dpkg -i ${repo_package_deb} && apt-get update",
      path    => '/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/bin',
      unless  => "dpkg -l ${repo_package_name} | grep -E '^ii'",
    }

    package { $packages:
      ensure => latest
    }
  }
}
