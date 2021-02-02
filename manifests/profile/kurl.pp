# Class: workstation::profile::kurl
# =================================
#
# Base installation and configuration of container runtime and kubernetes
# using kurl.sh to perform the installation.
#
# Parameters
# ----------
#
# @param url
#   The https://kurl.sh url for the configured kurl bash installer to
#   download and execute.
# @param user
#   The user account to execute as when installing.
# @param timeout
#   Number of seconds to allow kurl.sh to complete before raising
#   an error.
class workstation::profile::kurl(
  String $url,
  String $user,
  Integer $timeout = 1200,
) {

  $home = "/home/${user}"
  $unattended_patch = "${home}/kurl-sh-unattended.yaml"
  $curl = "curl -sSL -o kurl-installer.sh ${url}"
  $execute = "sudo bash ${home}/kurl-installer.sh installer-spec-file=${unattended_patch}"

  $installer = [
    $curl,
    $execute,
  ].join(' && ')

  file { $unattended_patch:
    source => "puppet:///modules/workstation/kurl-sh-unattended.yaml",
    owner  => $user,
    mode   => "0600",
  }
  -> exec { "Install kurl via ${url}":
    command     => $installer,
    path        => $facts['path'],
    user        => $user,
    cwd         => "/home/${user}",
    timeout     => $timeout,
    unless      => 'which kubectl && kubectl get nodes',
    environment => ["USER=${user}", "HOME=${home}"],
  }
}
