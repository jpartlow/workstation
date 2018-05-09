# Defined Type: workstation::repo::remote
# =======================================
#
# Add a remote fork to a clone of a git repository.
#
# Parameters
# ----------
#
# @param repo_dir [String] path to the repository we're going to add the remote to.
# @param remote [String] name of the remote to add.
# @param git_source_url [String] git uri to the repository fork we're adding.
# @param $local_user [String] local user account to execut the git remote add as.
define workstation::repo::remote(
  String $repo_dir,
  String $remote,
  String $git_source_url,
  String $local_user,
) {
  exec { "Set ${remote} remote for ${repo_dir}":
    command => "git remote add ${remote} ${git_source_url}",
    path    => "/usr/bin:/usr/bin/local",
    cwd     => $repo_dir,
    user    => $local_user,
  }
}
