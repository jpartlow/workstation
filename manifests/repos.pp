# Defined Type: workstation::repos
# ================================
#
# Clones a sets of git repositories into various work paths.
#
# $workstation::repository_sources is expected to be an array of hashes of
# structured data which can be fed into workstation::repo.
#
# Example:
#   [
#     {
#       'source' => 'git@github.com:puppetlabs/puppetlabs-puppet_enterprise'
#     },
#     {
#       'source' => 'git@github.com:puppetlabs/puppetlabs-pe_install'
#     },
#     ...
#   ]
#
# The set of acceptable keys is determined by the parameters of
# workstation::repo, but at a minimum, 'source' should be set.
#
# If a $default_options is passed, this hash should also be a set of
# workstation::repo keys that serve as defaults for each repo we create. So
# each entry in the $repository_sources will be merged into $default_options
# before being passed to a workstation::repo.
#
# Parameters
# ----------
#
# @param repository_sources [Array<Hash>] Array of workstation::repo parameter hashs.
# @param user [String] User to clone for. Defaults to workstation::user::account
# @param default_options [Optional[Hash]] An optional set of workstation::repo
#   parameters to be added to each repo.
# @param identity [String] SSH key to use during clone; must be either a
#   passwordless key accessible to root, or one in an ssh-agent accessible by
#   SSH_AUTH_SOCK
define workstation::repos(
  Array[Hash] $repository_sources,
  String $user,
  Optional[Hash] $default_options = {},
  String $identity = 'id_rsa',
  String $path = $title,
) {

  $repository_sources.each |$parameters| {
    $repo_params = {
      'github_user' => $user,
      'identity'    => $identity,
      'path'        => $path,
    } + $default_options + $parameters

    $source_title = "Clone ${$repo_params['source']} into ${$repo_params['path']}"
    $name_title = $repo_params['clone_name'] ? {
      undef   => '',
      default => " as ${$repo_params['clone_name']}"
    }

    workstation::repo { "${source_title}${name_title}":
      *       => $repo_params
    }
  }
}
