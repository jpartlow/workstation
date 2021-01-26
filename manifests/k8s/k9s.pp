class workstation::k8s::k9s(
  String $version = 'latest',
) {
  workstation::install_release_binary { 'derailed/k9s/k9s_Linux_x86_64.tar.gz':
    creates => 'k9s'
  }
}
