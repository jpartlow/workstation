# Class: workstation::k8s::krew
# =============================
#
# Install the krew plugin for kubectl into the given user's homedir.
# (The krew installer just dumps into ~/.krew, apparently.)
#
# Parameters
# ----------
#
# @param user
#   The user to install krew for.
class workstation::k8s::krew(
  String $user, 
) {

  package { 'git':
    ensure => 'latest',
  }

  $common_exec = {
    path        => $facts['path'],
    user        => $user,
    environment => [
      "HOME=/home/${user}",
      "USER=${user}",
    ]
  }

  $krew_installer = @(KREWINSTALL/L)
    cd "$(mktemp -d)" && \
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.tar.gz" && \
    tar zxvf krew.tar.gz && \
    KREW=./krew-"$(uname | tr '[:upper:]' '[:lower:]')_amd64" && \
    "$KREW" install krew
    | - KREWINSTALL

  exec { 'krew-install':
    command => $krew_installer,
    unless  => 'kubectl krew',
    require => Package['git'],
    *       => $common_exec,
  }

  $krew_path = @(KREWPATH)
    echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> ~/.bashrc
    | - KREWPATH
  $krew_path_unless = @(KREWPATHUNLESS)
    grep -qE 'export.*PATH.*\.krew' ~/.bashrc
    | - KREWPATHUNLESS

  exec { 'add-krew-to-path':
    command => $krew_path,
    unless  => $krew_path_unless,
    *       => $common_exec,
  }
}
