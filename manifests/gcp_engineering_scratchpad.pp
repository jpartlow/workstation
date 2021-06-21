# workstation::gcp_engineering_scratchpad
# =======================================
#
# Sets up resolver to use internal dns for GCP compute vms that are in the
# engineering-scratchpad project and are set up with our subnet.
#
# The default nameserver is our internal ip.
class workstation::gcp_engineering_scratchpad(
  Array[String] $nameservers = ['10.240.0.10']
) {
  case $facts['os']['family'] {
    'RedHat': {
      ini_setting { 'NetworkManager dns':
        ensure  => present,
        path    => '/etc/NetworkManager/NetworkManager.conf',
        section => 'main',
        setting => 'dns',
        value   => 'none',
      }
      ~> service { 'NetworkManager':
        ensure => running,
      }
      -> class { 'resolv_conf':
        nameservers => $nameservers,
      }
    }
    'Debian': {
      ini_setting { 'Resolved.conf':
        ensure  => present,
        path    => '/etc/systemd/resolved.conf',
        section => 'Resolve',
        setting => 'DNS',
        value   => $nameservers.join(','),
      }
      ~> service { 'systemd-resolved':
        ensure => running,
      }
    }
    default: { fail("Unsupported platform ${facts['os']['family']}") }
  }
}
