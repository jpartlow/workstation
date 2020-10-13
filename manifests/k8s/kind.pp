# Class: workstation::k8s::kind
# =============================
#
# Install the kind cli tool.
class workstation::k8s::kind() {

  $kind_installer = @(KIND/L)
    cd $(mktemp -d) && \
    VERSION=$(curl -sSL -o /dev/null --write-out '%{url_effective}' https://github.com/kubernetes-sigs/kind/releases/latest | grep -oE '[0-9]+\.[0-9]+\.[0-9]+') && \
    curl -sSL -o ./kind https://kind.sigs.k8s.io/dl/v${VERSION}/kind-linux-amd64 && \
    chmod +x ./kind && \
    mv ./kind /usr/bin
    | - KIND

  exec { 'install-kind':
    command => $kind_installer,
    path    => $facts['path'],
    creates => '/usr/local/bin/kind',
  }
}
