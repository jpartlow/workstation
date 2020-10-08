# Class: workstation::k8s
#
# Controls setup of kubernettes on a centos node.
# Tested against Centos 7.6.
#
# Parameters
# ----------
#
# @param docker_channel
#   The Docker repository channel to download packages from.
#   (stable, test or nightly)
# @param enable_debuginfo_repo
#   Whether to enable packages with debuginfo.
# @param enable_source_repo
#   Whether to enable source packages.
# @param krew_user
#   The user to install the Krew tool for.
# @param additional_packages
#   A list of other packages to install.
class workstation::k8s(
  String $docker_channel = 'stable',
  Boolean $enable_debuginfo_repo = false,
  Boolean $enable_source_repo = false,
  String $krew_user = 'centos',
  Array[String] $additional_packages = [],
) {
  class { 'workstation::k8s::repos':
    docker_channel        => $docker_channel,
    enable_debuginfo_repo => $enable_debuginfo_repo,
    enable_source_repo    => $enable_source_repo,
  }
  contain 'workstation::k8s::repos'

  package { ['docker-ce-cli', 'docker-ce']:
    ensure  => 'latest',
    require => Class['workstation::k8s::repos'],
  }

  package { ['kubelet', 'kubectl', 'kubeadm']:
    ensure  => 'latest',
    require => Class['workstation::k8s::repos'],
  }

  package { $additional_packages:
    ensure => 'latest',
  }

  class { 'workstation::k8s::krew':
    user    => $krew_user,
    require => Package['kubectl'],
  }
  contain 'workstation::k8s::krew'

  service { 'docker':
    ensure  => 'running',
    require => Package['docker-ce'],
  }
}
