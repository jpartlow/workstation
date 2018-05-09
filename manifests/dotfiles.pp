# Class: workstation::dotfiles
# ============================
#
# Sets up configuration files from a repo.
#
# Parameters
# ----------
#
# @param user [String] User to clone as.
# @param identity [String] SSH key to authenticate to github with.
# @param repo_source [String] The dotfile repo source url.
# @param homedir [String] The user's home directory.
# @param clone_path [String] The path to clone the dotfiles repo to. Defaults to $homedir.
class workstation::dotfiles(
  String $user,
  String $identity,
  String $repo_source = "git@github.com:${user}/dotfiles",
  String $homedir     = "/home/${user}",
  String $clone_path  = $homedir,
) {
  workstation::repo { 'dotfiles':
    source             => $repo_source,
    github_user        => $user,
    identity           => $identity,
    path               => $clone_path,
  }
  -> exec { 'sync dotfiles':
    command => "${clone_path}/dotfiles/synch.sh -d ${homedir}"
  }
}
