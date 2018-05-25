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
) {
  workstation::repo { 'dotfiles':
    bare        => true,
    source      => $repo_source,
    github_user => $user,
    identity    => $identity,
    path        => $homedir,
    clone_name  => '.dotfiles',
  }

  $_git_command = "/usr/bin/git --git-dir='${homedir}/.dotfiles' --work-tree='${homedir}'"
  $command = "${_git_command} checkout && ${_git_command} config --local status.showUntrackedFiles no"
  exec { 'initial checkout':
    command => $command,
    cwd     => $homedir,
    path    => '/usr/bin:/bin',
    user    => $user,
    onlyif  => "${_git_command} status --porcelain | grep '^D'",
    require => Workstation::Repo['dotfiles'],
  }
}
