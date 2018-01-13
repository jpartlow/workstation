# Class: workstation::dotfiles
# ============================
#
# Sets up configuration files from a repo.
#
# Parameters
# ----------
#
# @param user [String] User to clone as. 
# @param repo_source [String] The dotfile repo source url.
# @param homedir [String] The user's home directory.
# @param clone_path [String] To clone to. Defaults to /home/$user/dotfiles
class workstation::dotfiles(
  String $user = $::workstation::user::account,
  String $repo_source = "git@github.com:${user}/dotfiles",
  String $homedir = "/home/${user}",
  String $clone_path = "/${homedir}/dotfiles",
) {
  workstation::repos { 'dotfiles':
    repository_sources => [$repo_source],
    user               => $user,
    path               => $clone_path,
  }
  -> exec { 'sync dotfiles':
    command => "${clone_path}/sync.sh -d ${homedir}"
  }
}
