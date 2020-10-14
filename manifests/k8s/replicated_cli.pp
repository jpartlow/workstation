# Class: workstation::k8s::replicated_cli
# =======================================
#
# Install the replicated cli tool into /usr/local/bin.
class workstation::k8s::replicated_cli() {

  $replicated_installer = "curl -sSL https://raw.githubusercontent.com/replicatedhq/replicated/master/install.sh | bash"
  $installed_to = '/usr/local/bin/replicated'

  exec { 'replicated-cli-install':
    command => $replicated_installer,
    path    => $facts['path'],
    creates => $installed_to,
  }

  # Installer script is leaving owner/group from tarball
  file { $installed_to:
    owner => 'root',
    group => 'root',
    mode  => '0755',
  }
}
