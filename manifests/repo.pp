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
# @param checkout_branch [Optional[String]] An optional branch to checkout.
#   Will also set to upstream if an upstream remote is set.
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
  Optional[String] $checkout_branch = undef,
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
    ensure     => $_ensure,
    provider   => git,
    submodules => false,
    source     => $source,
    owner      => $local_user,
    group      => $local_user,
    user       => $github_user,
    identity   => $identity, # required for git to find the key from ssh-agent
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
      fetch_remote   => true,
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

  if !empty($checkout_branch) {
    if !empty($upstream) {
      $_remote = 'upstream'
      $_checkout_requires = [Workstation::Repo::Remote["${repo_dir}:upstream"]]
    } else {
      $_remote = 'origin'
      $_checkout_requires = []
    }

    $_checkout_branch_exec = "Setup branch ${checkout_branch} for ${repo_dir}"
    exec { $_checkout_branch_exec:
      command => "git checkout -b ${checkout_branch} -t ${_remote}/${checkout_branch}",
      unless  => "git branch | grep -qE '^[ *]+${checkout_branch}$'",
      path    => '/usr/bin:/usr/bin/local:/bin',
      cwd     => $repo_dir,
      user    => $local_user,
      require => $_checkout_requires,
    }

    # A branch that is already in the fork will not get set by the above checkout,
    # so ensure upstream tracking here.
    if !empty($upstream) {
      exec { "Ensure upstream tracking for ${checkout_branch} in ${repo_dir}":
        command => "git checkout ${checkout_branch} && git branch -u ${_remote}/${checkout_branch} && git pull && chown -R ${local_user}:${local_user} ${repo_dir}",
        unless  => "git config --get branch.${checkout_branch}.remote | grep -qE '^${_remote}$'",
        path    => '/usr/bin:/usr/bin/local:/bin',
        cwd     => $repo_dir,
        require => Exec[$_checkout_branch_exec],
      }
    }
  }
}
