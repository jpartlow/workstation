# Class: workstation::k8s::replicated_cli
# =======================================
#
# Install the replicated cli tool into /usr/local/bin.
class workstation::k8s::replicated_cli() {

  $replicated_installer = "curl -sSL https://raw.githubusercontent.com/replicatedhq/replicated/master/install.sh | bash"

  exec { 'replicated-cli-install':
    command => $replicated_installer,
    path    => $facts['path'],
    creates => '/usr/local/bin/replicated',
  }
}
