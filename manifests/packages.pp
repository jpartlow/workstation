# Class: workstation::packages
#
# Simplifies specifying dependencies on packages in general.
class workstation::packages(
  Array[String] $packages = [],
  Boolean $install_epel = true,
) {
  # It's a safe bet that dev packages will need epel on el hosts.
  if !empty($packages) and $install_epel and $facts['os']['family'] == 'RedHat' {
    package { 'epel-release':
      ensure => present,
    }
    $package_params = {
      require       => Package['epel-release'],
    }
  } else {
    $package_params = {}
  }

  package { $packages:
    ensure => latest,
    *      => $package_params,
  }
}
