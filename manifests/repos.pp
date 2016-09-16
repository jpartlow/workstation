# Defined Type: workstation::repos
# ================================
#
# Clones a set of git repositories into a work path.
#
# Parameters
# ----------
#
# @param repository_sources [Array<String>] Of repository source urls.
# @param user [String] User to clone as. Defaults to workstation::user::account
# @param path [String] To clone to. Defaults to /home/$user/work/src
# 
define workstation::repos(
  Array[String] $repository_sources,
  String $user = $::workstation::user::account,
  String $path = "/home/${user}/work/src",
) {

  file { $path:
    ensure => present,
  }

  $repository_sources.each |$repo| {
    $matches = $repo.match(/\/(.*)$/)
    vcsrepo { "${path}/${matches[1]}":
      ensure   => present,
      provider => git,
      source   => $repo,
      user     => $user,
    }
  }
}
