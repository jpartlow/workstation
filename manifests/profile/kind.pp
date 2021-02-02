# Class: workstation::profile::kind
# =================================
#
# Controls setup of kubernettes and KIND on a centos node.
#
# The base docker installation is docker-ce from docker.com yum repos.
# The kubernetes packages come from google.com yum repos.
# (see workstation::k8s::repos)
#
# For management of the kubernetes cluster KinD is installed, *but* the
# manifest does not initialize the cluster. You will need to do that yourself
# with kind and whatever supporting config is required after the manifest
# finishes.
#
# Manages
# -------
#
# * docker and k8s yum repositories
# * docker-ce/docker-ce-cli
# * kubectl/kubeadm/kubelet
# * KinD
#
# Parameters:
# -----------
#
# @param docker_channel
#   The Docker repository channel to download packages from.
#   (stable, test or nightly)
# @param enable_debuginfo_repo
#   Whether to enable packages with debuginfo.
# @param enable_source_repo
#   Whether to enable source packages.
# @param docker_user
#   Add this user to the docker group.
class workstation::profile::kind(
  String $docker_channel = 'stable',
  Boolean $enable_debuginfo_repo = false,
  Boolean $enable_source_repo = false,
  String $docker_user = 'centos',
) {
  class { 'workstation::profile::k8s':
    dev_user              => $docker_user,
    docker_channel        => $docker_channel,
    enable_debuginfo_repo => $enable_debuginfo_repo,
    enable_source_repo    => $enable_source_repo,
  }
  contain 'workstation::profile::k8s'

  workstation::install_release_binary { 'kubernetes-sigs/kind/kind-linux-amd64':
    creates     => 'kind',
    install_dir => '/usr/bin',
  }
}
