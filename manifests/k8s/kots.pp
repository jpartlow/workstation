# Class: workstation::k8s::kots
# =============================
#
# Add the kots plugin to kubectl.
class workstation::k8s::kots() {

  $kots_installer = 'curl https://kots.io/install | bash'
  $installed_to = '/usr/local/bin/kubectl-kots'

  exec { 'kots-install':
    command => $kots_installer,
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
