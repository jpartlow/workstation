# Class: workstation::k8s::k9s
# ============================
#
# Install the k9s cli tool.
class workstation::k8s::k9s() {

  $k9s_installer = @(K9S/L)
    cd $(mktemp -d) && \
    VERSION=$(curl -sSL -o /dev/null --write-out '%{url_effective}' https://github.com/derailed/k9s/releases/latest | grep -oE '[0-9]+\.[0-9]+\.[0-9]+') && \
    curl -fsSL -O "https://github.com/derailed/k9s/releases/download/v${VERSION}/k9s_Linux_x86_64.tar.gz" && \
    tar -xf k9s_Linux_x86_64.tar.gz && \
    mv k9s /usr/local/bin
    | - K9S

  exec { 'install-k9s':
    command => $k9s_installer,
    path    => $facts['path'],
    creates => '/usr/local/bin/k9s',
  }
}
