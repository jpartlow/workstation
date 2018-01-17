# Defined Type: workstation::repos
# ================================
#
# Clones a set of git repositories into a work path.
#
# Parameters
# ----------
#
# @param repository_sources [Array<String>] Of repository source urls.
# @param user [String] User to clone for. Defaults to workstation::user::account
# @param identity [String] SSH key to use during clone; must be either a
#   passwordless key accessible to root, or one in a puppet-agent accessible by
#   SSH_AUTH_SOCK
# @param path [String] To clone to. Defaults to /home/$user/work/src
# 
define workstation::repos(
  Array[String] $repository_sources,
  String $user = $::workstation::user::account,
  String $identity = 'id_rsa',
  String $path = "/home/${user}/work/src",
) {

  $repository_sources.each |$repo| {
    $matches = $repo.match(/\/(.*)$/)
    vcsrepo { "${path}/${matches[1]}":
      ensure   => present,
      provider => git,
      source   => $repo,
      owner    => $user,
      group    => $user,
      user     => $user,
      identity => $identity, # required for git to find the key from ssh-agent
      require  => File[$path],
    }
  }
}
