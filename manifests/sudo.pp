# Class: workstation::sudo
# ========================
# 
# Ensure that the user account has passwordless sudo.
class workstation::sudo(
  String $user = $::workstation::user::account
) {
  class { 'sudo':
    purge               => false,
    config_file_replace => false,
  }
  sudo::conf { $user:
    ensure          => 'present',
    content         => "${user} ALL=(ALL) NOPASSWD:ALL",
  }
}
