# Class: workstation::profile::k8s
# ================================
#
# Base installation of container runtime and kubernetes.
#
# Handles setting up packaging repos, installing either
# docker-ce or just containerd, and the base k8s kubectl,
# kubelete, kubeadm packages.
#
# Limitations: el only; only el7 tested so far.
#
class workstation::profile::k8s(
  String $dev_user = 'centos',
  String $docker_channel = 'stable',
  Boolean $enable_debuginfo_repo = false,
  Boolean $enable_source_repo = false,
  Enum['docker','containerd'] $container_type = 'docker',
  Array[String] $k8s_packages = ['kubelet', 'kubeadm', 'kubectl'],
) {
  class { 'workstation::k8s::repos':
    docker_channel        => $docker_channel,
    enable_debuginfo_repo => $enable_debuginfo_repo,
    enable_source_repo    => $enable_source_repo,
  }
  contain 'workstation::k8s::repos'

  $container_packages = $container_type ? {
    'containerd' => ['containerd.io'],
    default      => ['docker-ce-cli', 'docker-ce'],
  }
  package { $container_packages:
    ensure  => 'latest',
    require => Class['workstation::k8s::repos'],
  }

  package { $k8s_packages:
    ensure  => 'latest',
    require => Class['workstation::k8s::repos'],
  }

  case $container_type {
    'docker': {
      service { 'docker':
        ensure  => 'running',
        require => Package['docker-ce'],
      }

      user { $dev_user:
        ensure  => present,
        groups  => ['docker'],
        require => Package['docker-ce'],
      }
    }
    default: {}
  }
}
