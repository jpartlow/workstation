# Class: workstation::k8s::kots
# =============================
#
# Add the kots plugin to kubectl.
class workstation::k8s::kots() {

  $kots_installer = 'curl https://kots.io/install | bash'

  exec { 'kots-install':
    command => $kots_installer,
    path    => $facts['path'],
    creates => '/usr/local/bin/kubectl-kots',
  }
}
