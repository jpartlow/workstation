# Class: workstation::k8s::repos
# ==============================
#
# Contains the resources for configuring repositories relevant to
# installing k8s packages. Separated as a class for ordering and
# containment purposes
#
# Parameters
# ----------
#
# (See workstation::k8s)
class workstation::k8s::repos(
  String $docker_channel,
  Boolean $enable_debuginfo_repo,
  Boolean $enable_source_repo,
) {

  # Centos Extras
  yumrepo { 'extras':
    ensure     => 'present',
    descr      => 'CentOS-$releasever - Extras',
    mirrorlist => 'http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=extras&infra=$infra',
    enabled    => 1,
    gpgcheck   => 1,
    gpgkey     => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7',
    notify     => Exec['yum-clean-all'],
  }

  # Docker Engine
  [
    'stable',
    'test',
    'nightly',
  ].each |$channel| {
    $enable_channel = ($docker_channel == $channel)

    workstation::k8s::docker_repos { $channel:
      channel          => $channel,
      enabled          => $enable_channel,
      enable_debuginfo => $enable_debuginfo_repo,
      enable_source    => $enable_source_repo,
      notify           => Exec['yum-clean-all'],
    }
  }

  # Kubernetes
  yumrepo { 'kubernetes':
    ensure        => 'present',
    descr         => 'Kubernetes',
    baseurl       => 'https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64',
    enabled       => 1,
    gpgcheck      => 1,
    gpgkey        => 'https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg',
    repo_gpgcheck => 1,
    notify           => Exec['yum-clean-all'],
  }

  exec { 'yum-clean-all':
    command     => '/usr/bin/yum clean all',
    refreshonly => true,
  }
}
