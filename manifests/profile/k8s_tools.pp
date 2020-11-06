# Class: workstation::profile::k8s_tools
# ======================================
#
# Tools useful for any k8s installation.
#
# * k9s
# * helm
class workstation::profile::k8s_tools(
  String $dev_user = 'centos',
  String $helm_version = 'latest',
  Array[Workstation::Chart_repo] $additional_chart_repos = [],
) {
  workstation::install_release_binary { 'derailed/k9s/k9s_Linux_x86_64.tar.gz':
    creates => 'k9s'
  }

  class { 'workstation::k8s::helm':
    user        => $dev_user,
    version     => $helm_version,
    chart_repos => $additional_chart_repos,
  }
  contain 'workstation::k8s::helm'
}
