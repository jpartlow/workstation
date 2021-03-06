# Class: workstation::profile::holodeck
# =====================================
#
# Adds tools for testing and dev work used by the
# [holodeck-manifests](https://github.com/puppetlabs/holodeck-manifests)
# repository.
#
# Be aware that there is a lot of `curl | bash` and downloads from github
# releases going on for these various third party tools that aren't using
# package managers, and there is currently no attempt to validate checksums
# or signatures (if such things exist). So I wouldn't use this on anything
# other than a dev host.
#
# Tested against Centos 7.6.
#
# Manages
# -------
#
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
# * jq
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
# @param kots_version
#   The KOTS version to install. Defaults to latest.
# @param helm_version
#   The helm version to install. Defaults to latest.
# @param kustomize_version
#   The kustomize version to install. Defaults to latest.
# @param yq_version
#   The yq version to install. Defaults to latest.
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
  String $kots_version = 'latest',
  String $helm_version = 'latest',
  String $kustomize_version = 'latest',
  String $yq_version = 'latest',
  String $dev_user = 'centos',
  Array[Workstation::Chart_repo] $additional_chart_repos = [],
  Array[String] $additional_packages = [],
) {
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
    kustomize_version      => $kustomize_version,
    additional_chart_repos => $default_chart_repos + $additional_chart_repos,
  }
  contain 'workstation::profile::k8s_tools'

  class { 'workstation::k8s::krew':
    user    => $dev_user,
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

  workstation::install_release_binary { 'mikefarah/yq/yq_linux_amd64.tar.gz':
    version      => $yq_version,
    archive_file => 'yq_linux_amd64',
    creates      => 'yq',
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
  file { "/home/${dev_user}/bin/cycle-app":
    source => 'puppet:///modules/workstation/cycle-app',
    owner  => $dev_user,
    mode   => '0750',
  }
}
