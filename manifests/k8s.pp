# Class: workstation::k8s
#
# Controls setup of kubernettes and related tools on a centos node.
#
# The base docker installation is docker-ce from docker.com yum repos.
# The kubernetes packages come from google.com yum repos.
# (see workstation::k8s::repos)
#
# For management of the kubernetes cluster KinD is installed, *but* the manifest
# does not initialize the cluster. You will need to do that yourself with kind and
# whatever supporting config is required after the manifest finishes.
#
# Also be aware that outside of the established package channels mentioned
# above, there is a lot of `curl | bash` and downloads from github releases
# going on for these various third party tools that aren't using package
# managers, and there is currently no attempt to validate checksums or
# signatures (if such things exist). So I wouldn't use this on anything other
# than a dev host.
#
# Tested against Centos 7.6.
#
# Parameters
# ----------
#
# @param replicated_license_file
#   Absolute path to the license file to transfer to the dev host
#   so that we can install cd4pe via KOTS. The file will be placed
#   in /home/${dev_user}, but can be linked elsewhere with $license_links.
# @param license_links
#   Array of absolute paths to be created as symlinks to the
#   $replicated_license_file placed on the dev host.
# @param docker_channel
#   The Docker repository channel to download packages from.
#   (stable, test or nightly)
# @param enable_debuginfo_repo
#   Whether to enable packages with debuginfo.
# @param enable_source_repo
#   Whether to enable source packages.
# @param kots_version
#   The KOTS version to install. Defaults to latest.
# @param heml_version
#   The helm version to install. Defaults to latest.
# @param dev_user
#   Install unprivileged tools like krew, and add helm chart repos
#   for this user. (Any tool that needs to work with local user
#   config, basically).
# @param additional_chart_repos
#   Array of chart repository hashes (name, url) to add to helm.
# @param additional_packages
#   Array of extra packages to add.
class workstation::k8s(
  Workstation::Absolute_path $replicated_license_file,
  Array[Workstation::Absolute_path] $license_links = [],
  String $docker_channel = 'stable',
  Boolean $enable_debuginfo_repo = false,
  Boolean $enable_source_repo = false,
  String $kots_version = 'latest',
  String $helm_version = 'latest',
  String $dev_user = 'centos',
  Array[Workstation::Chart_repo] $additional_chart_repos = [],
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

  class { 'workstation::k8s::krew':
    user    => $dev_user,
    require => Package['kubectl'],
  }
  contain 'workstation::k8s::krew'

  workstation::bash_installer { 'replicated-cli':
    url     => 'https://raw.githubusercontent.com/replicatedhq/replicated/master/install.sh',
    creates => '/usr/local/bin/replicated',
  }

  workstation::install_release_binary { 'replicatedhq/kots/kots_linux_amd64.tar.gz':
    version      => $kots_version,
    archive_file => 'kots',
    creates      => 'kubectl-kots',
  }

  workstation::k8s::krew_plugin { 'preflight':
    user    => $dev_user,
    require => Class['workstation::k8s::krew'],
  }

  workstation::k8s::krew_plugin { 'support-bundle':
    user    => $dev_user,
    creates => 'support_bundle',
    require => Class['workstation::k8s::krew'],
  }

  workstation::install_release_binary { 'derailed/k9s/k9s_Linux_x86_64.tar.gz':
    creates => 'k9s'
  }

  workstation::install_release_binary { 'kubernetes-sigs/kind/kind-linux-amd64':
    creates     => 'kind',
    install_dir => '/usr/bin',
  }

  # The holodock-manifests Makefile expects to be able to install gitlab
  # using helm, and requires this repository added.
  $default_chart_repos = [
    {
      name => 'gitlab',
      url => 'https://charts.gitlab.io/',
    }
  ]
  class { 'workstation::k8s::helm':
    user        => $dev_user,
    version     => $helm_version,
    chart_repos => $default_chart_repos + $additional_chart_repos,
  }
  contain 'workstation::k8s::helm'

  # This is a configuration testing tool used by holodeck-manifests unit tests
  # to validate container configurations.
  workstation::install_release_binary { 'open-policy-agent/conftest/conftest_${VERSION}_Linux_x86_64.tar.gz':
    creates => 'conftest',
  }

  # This has nothing to do with k8s specifically, but the holodeck-manifests
  # Makefile makes use of jq to manipulate JSON data returned by PE status
  # endpoints and the like.
  $default_packages = [
    'jq',
  ]
  package { ($default_packages + $additional_packages):
    ensure => 'latest',
  }

  service { 'docker':
    ensure  => 'running',
    require => Package['docker-ce'],
  }

  user { $dev_user:
    ensure  => present,
    groups  => ['docker'],
    require => Package['docker-ce'],
  }

  $license_file = $replicated_license_file.split(/\//)[-1]
  $dev_host_license_path = "/home/${dev_user}/${license_file}"
  file { $dev_host_license_path:
    ensure  => 'present',
    content => file($replicated_license_file),
    mode    => '0640',
    owner   => $dev_user,
    group   => $dev_user,
  }

  $license_links.each |$link| {
    file { $link:
      ensure => 'link',
      target => $dev_host_license_path,
    }
  }
}
