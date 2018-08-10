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
# @param $fetch_remote [Boolean] if true perform a fetch if the remote if it has not been done yet.
define workstation::repo::remote(
  String $repo_dir,
  String $remote,
  String $git_source_url,
  String $local_user,
  Optional[Boolean] $fetch_remote = false,
) {
  $_add_remote_exec = "Set ${remote} remote for ${repo_dir}"
  exec { $_add_remote_exec:
    command => "git remote add ${remote} ${git_source_url}",
    unless  => "git remote | grep -q ${remote}",
    path    => '/usr/bin:/usr/bin/local:/bin',
    cwd     => $repo_dir,
    user    => $local_user,
  }

  if $fetch_remote {
    exec { "Fetch ${remote}":
      command => "git remote fetch ${remote}",
      unless  => "git branch -r | grep -qE '^\\s+${remote}'",
      path    => '/usr/bin:/usr/bin/local:/bin',
      cwd     => $repo_dir,
      user    => $local_user,
      require => Exec[$_add_remote_exec],
    }
  }
}
