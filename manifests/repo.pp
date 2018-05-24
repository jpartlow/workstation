# Defined Type: workstation::repo
# ===============================
#
# Configures one git repository.
#
# The $source parameter assumes an ssh git protocol url such as:
#
#   git@github.com:puppetlabs/puppetlabs-puppet_enterprise
#
# Parameters
# ----------
#
# @param source [String] the github url for the repository.
# @param path [String] the local filesystem directory we will clone the repository into.
# @param github_user [Optional[String]] the github user to clone as. Optional if source is
#   public.
# @param identity [Optional[String]] the ssh key to authenticate to github with. Optional
#   if source is public.
# @param local_user [String] the local user account owning the repo.
# @param clone_name [Optional[String]] the local name of the repo directory we
#   will clone into in $path. If not set, this is taken from $source repo name.
# @param upstream [Optional[String]] if set, this represents the account that has the
#   original upstream version of the repository, of which our clone's origin is a
#   downstream fork. Adds an upstream remote pointing to the source rewritten
#   with $upstream as the account.
# @param remotes [Array<String>] an array of github accounts representing
#   additional remote forks to be added. May be empty.
# @param bare [Boolean] if true then the checkout will be a bare git clone.
define workstation::repo(
  String $source,
  String $path,
  Optional[String] $github_user,
  Optional[String] $identity,
  String $local_user = $github_user,
  Optional[String] $clone_name = undef,
  Optional[String] $upstream = undef,
  Array[String] $remotes = [],
  Boolean $bare = false,
) {
  $matches = $source.match(/^(.+):([^:]+)\/([^\/]+)$/)
  $protocol = $matches[1]
  $fork = $matches[2]
  $repo_name = $matches[3]

  $_clone_name = $clone_name ? {
    undef   => $repo_name,
    ''      => $repo_name,
    default => $clone_name,
  }
  $repo_dir = "${path}/${_clone_name}"

  $_ensure = $bare ? {
    true    => 'bare',
    default => 'present',
  }
  vcsrepo { $repo_dir:
    ensure   => $_ensure,
    provider => git,
    source   => $source,
    owner    => $local_user,
    group    => $local_user,
    user     => $github_user,
    identity => $identity, # required for git to find the key from ssh-agent
  }

  $remote_options = {
    local_user     => $local_user,
    require        => Vcsrepo[$repo_dir],
  }

  if !empty($upstream) {
    workstation::repo::remote { "${repo_dir}:upstream":
      remote         => 'upstream',
      git_source_url => "${protocol}:${upstream}/${repo_name}",
      repo_dir       => $repo_dir,
      *              => $remote_options,
    }
  }

  $remotes.each |$remote| {
    workstation::repo::remote { "${repo_dir}:${remote}":
      remote         => $remote,
      git_source_url => "${protocol}:${remote}/${repo_name}",
      repo_dir       => $repo_dir,
      *              => $remote_options,
    }
  }
}
