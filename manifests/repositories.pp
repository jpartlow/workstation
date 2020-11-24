# Class: workstation::repositories
# ================================
#
# Contains all git repository checkout and setup.
#
# Clones sets of git repositories into various work paths as specified by
# $workstation::data.
#
# $workstation::data is expected to be an array of hashes of
# structured data which can be fed into workstation::repos.
#
# Each hash in the array must contain a 'path' string for the directory that
# the repositories are in the 'repos' array are to be created in. If the path
# is relative, it will be prepended with '/home/$user/'.
#
# Each hash in the array should contain a 'repos' array of hashes, where each
# hash contains keys mapping to the parameters of a workstation::repo defined
# type.
#
# Each hash in the array may contain a 'defaults' hash of options common to
# every element of 'repos'. The parameters in each hash of 'repos' will take
# precedence.
#
# Example:
#   [
#     {
#       'path'       => 'some/path',
#       'defaults'   => {
#         'upstream' => 'puppetlabs',
#       },
#       'repos' => [
#         {
#           'source' => 'git@github.com:puppetlabs/puppetlabs-puppet_enterprise'
#         },
#         {
#           'source' => 'git@github.com:puppetlabs/puppetlabs-pe_install'
#         },
#       ]
#     },
#     ... # another set of repos with different defaults, probably to a different path
#   ]
#
# The set of acceptable keys is determined by the parameters of workstation::repo.
#
# Parameters
# ----------
#
# @param repository_data
#   Array of workstation::repos parameter hashes.
# @param user
#   User to clone for. Defaults to workstation::user::account
# @param identity
#   SSH key to use during clone; must be either a passwordless key accessible
#   to root, or one in an ssh-agent accessible by SSH_AUTH_SOCK
# @param mode
#   The permissions on subdirectory paths that we construct to place
#   repos into.
class workstation::repositories(
  Array[Hash] $repository_data,
  String $user,
  String $identity,
  String $mode = '0640',
) {
  $repository_data.each |$parameters| {
    case $parameters['path'] {
      /^\//: {
        $_root_prefix = ''
        $path = $parameters['path']
      }
      default: {
        $_root_prefix = "/home/${user}"
        $path = "${_root_prefix}/${parameters['path']}"
      }
    }

    $repo_names = $parameters['repos'].map |$params| {
      $repo_name = regsubst($params['source'], '^.*/([^/]+)$', '\1')
      $params['clone_name'] ? {
        undef   => $repo_name,
        default => $params['clone_name'],
      }
    }

    workstation::make_p { "Generating ${path} for ${repo_names}":
      path        => $parameters['path'],
      root_prefix => $_root_prefix,
      user        => $user,
      mode        => $mode,
    }

    workstation::repos { "${path}/${repo_names}":
      path               => $path,
      repository_sources => $parameters['repos'],
      default_options    => $parameters['defaults'],
      user               => $user,
      identity           => $identity,
    }
  }
}
