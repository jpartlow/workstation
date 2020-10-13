# Define: workstation::k8s::krew_plugin
# =====================================
#
# Generic type for installing a krew plugin.
#
# Parameters
# ----------
#
# @param plugin
#   The plugin to install
# @param user
#   The user account to install the plugin for
define workstation::k8s::krew_plugin(
  String $user,
  String $plugin = $title,
  String $creates = $title,
) {
  $home = "/home/${user}"

  exec { "install-${plugin}-for-krew":
    command => "kubectl krew install ${plugin}",
    path    => "${facts['path']}:${home}/.krew/bin",
    cwd     => $home,
    user    => $user,
    creates => "${home}/.krew/bin/kubectl-${creates}",
  }
}
