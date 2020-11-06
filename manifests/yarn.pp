# Class: workstation::k8s::nvm
# ============================
#
# Installs the nvm, node and yarn into the given user's home environment.
#
# Some holodeck-manifests targets are using yarn to managed their js
# dependencies. Yarn is a js package manager that we're installing via npm,
# another js package manager, after installing a version of nodejs with nvm
# (that includes npm)...
#
# The PipelinesInfra repo is using yarn; and holodeck-manifests is using
# the test suite in PipelinesInfra for integration testing with cd4pe.
#
# Parameters
# ----------
class workstation::yarn(
  String $user,
  String $nvm_version = '0.35.3',
  String $node_version = '12.8.0',
) {

  $installer = [
    "curl -sSL https://raw.githubusercontent.com/nvm-sh/nvm/v${nvm_version}/install.sh | bash",
    'NVM_DIR="${HOME}/.nvm"',
    '[ -s "${NVM_DIR}/nvm.sh" ] && . "${NVM_DIR}/nvm.sh"',
    "nvm install ${node_version}",
    "npm install -g yarn",
  ]

  $home = "/home/${user}"
  exec { 'install-yarn':
    command     => $installer.join(' && '),
    path        => $facts['path'],
    cwd         => $home,
    user        => $user,
    environment => ["USER=${user}", "HOME=${home}"],
    provider    => 'shell',
    unless      => "source ${home}/.nvm/nvm.sh && /usr/bin/which yarn",
  }
}
