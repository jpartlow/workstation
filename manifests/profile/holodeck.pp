# Class: workstation::profile::holodeck
#
# Controls setup of kubernettes and related tools on a centos node
# specifically to prepare that host for testing and dev work for the
# [holodeck-manifests](https://github.com/puppetlabs/holodeck-manifests)
# repository.
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
# Manages
# -------
#
# * docker and k8s yum repositories
# * docker-ce/docker-ce-cli
# * kubectl/kubeadm/kubelet
# * KinD
# * Kots
# * krew (and plugins)
#   * preflight
#   * support bundle
# * replicated-cli
# * helm
#   * gitlab helm chart repository
# * testing tools used by holodeck-manifests
#   * conftest (for spec manifest testing)
#   * yarn (for installing jest/puppeteer for workflow tests that exercise the cd4pe UI)
#   * chromium-headless
# * transferring required replicated/cd4pe license secrets from localhost to workstation for testing
#
# Parameters
# ----------
#
# @param replicated_licenses
#   Array of absolute pathes to license files to transfer to the dev host
#   so that we can install a replicated app via KOTS. The file will be placed
#   in /home/${dev_user}, but can be linked elsewhere with $license_links.
# @param license_links
#   Array of absolute paths to be created as symlinks to the
#   $replicated_licenses placed on the dev host.
# @param docker_channel
#   The Docker repository channel to download packages from.
#   (stable, test or nightly)
# @param enable_debuginfo_repo
#   Whether to enable packages with debuginfo.
# @param enable_source_repo
#   Whether to enable source packages.
# @param kots_version
#   The KOTS version to install. Defaults to latest.
# @param helm_version
#   The helm version to install. Defaults to latest.
# @param dev_user
#   Install unprivileged tools like krew, and add helm chart repos
#   for this user. (Any tool that needs to work with local user
#   config, basically).
# @param additional_chart_repos
#   Array of chart repository hashes (name, url) to add to helm.
# @param additional_packages
#   Array of extra packages to add.
class workstation::profile::holodeck(
  Array[Workstation::Absolute_path] $replicated_licenses,
  Workstation::Absolute_path $cd4pe_license_file,
  Optional[Workstation::License_links_struct] $license_links = {},
  String $docker_channel = 'stable',
  Boolean $enable_debuginfo_repo = false,
  Boolean $enable_source_repo = false,
  String $kots_version = 'latest',
  String $helm_version = 'latest',
  String $dev_user = 'centos',
  Array[Workstation::Chart_repo] $additional_chart_repos = [],
  Array[String] $additional_packages = [],
) {
  class { 'workstation::profile::k8s':
    dev_user              => $dev_user,
    docker_channel        => $docker_channel,
    enable_debuginfo_repo => $enable_debuginfo_repo,
    enable_source_repo    => $enable_source_repo,
  }
  contain 'workstation::profile::k8s'

  # The holodock-manifests Makefile expects to be able to install gitlab
  # using helm, and requires this repository added.
  $default_chart_repos = [
    {
      name => 'gitlab',
      url => 'https://charts.gitlab.io/',
    }
  ]
  class { 'workstation::profile::k8s_tools':
    dev_user               => $dev_user,
    helm_version           => $helm_version,
    additional_chart_repos => $default_chart_repos + $additional_chart_repos,
  }
  contain 'workstation::profile::k8s_tools'

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

  workstation::install_release_binary { 'kubernetes-sigs/kind/kind-linux-amd64':
    creates     => 'kind',
    install_dir => '/usr/bin',
  }

  workstation::install_release_binary { 'docker/compose/docker-compose-Linux-x86_64':
    creates        => 'docker-compose',
    version_prefix => '',
  }

  # Unit/integration testing tools and lib dependencies for holodeck-manifests
  class { 'workstation::k8s::holodeck_testing':
    dev_user => $dev_user,
  }
  contain 'workstation::k8s::holodeck_testing'

  # This has nothing to do with k8s specifically, but the holodeck-manifests
  # Makefile makes use of jq to manipulate JSON data returned by PE status
  # endpoints and the like.
  $default_packages = [
    'jq',
  ]
  package { ($default_packages + $additional_packages):
    ensure => 'latest',
  }

  zip($replicated_licenses, $license_links['replicated']).each |$a| {
    $license = $a[0]
    $links_array = $a[1] =~ Undef ? {
      true    => [],
      default => [ $a[1] ],
    }

    workstation::copy_secret_and_link { "copy-replicated-license ${license}":
      local_file => $license,
      user       => $dev_user,
      links      => $links_array,
    }
  }

  workstation::copy_secret_and_link { 'copy-cd4pe-license':
    local_file => $cd4pe_license_file,
    user       => $dev_user,
    links      => $license_links['cd4pe'],
  }

  workstation::make_p { 'bin':
    root_prefix => "/home/${dev_user}",
    user        => $dev_user,
    mode        => '0600',
  }
  file { "/home/${dev_user}/bin/cycle-tests":
    source => 'puppet:///modules/workstation/cycle-tests',
    owner  => $dev_user,
    mode   => '0750',
  }
}
