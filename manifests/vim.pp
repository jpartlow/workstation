# Class: workstation:vim
# ======================
#
# Manage vim configuration by getting pathogen in place and then cloning in
# plugins to picked up by pathogen from the .vim/bundle directory.
#
# Parameters
# ----------
#
# @param user [String] User account to setup vim for (affects default path and ownership).
# @param bundles [Array<Hash>] An array of workstation::repo parameter hashes
#   for vim bundle sources.
# @param vim_path [String] The vim configuration path to setup. Defaults to
#   "/home/${user}/.vim"
class workstation::vim(
  String $user,
  Array[Hash] $bundles,
  String $vim_path = "/home/${user}/.vim",
) {

  $vim_directories = [
    $vim_path,
    "${vim_path}/autoload",
    "${vim_path}/bundle",
  ]
  file { $vim_directories:
    ensure => 'directory',
    owner  => $user,
    group  => $user,
    mode   => '0644',
  }

  $pathogen_clone_path = "/home/${user}/work/src/other"
  workstation::repo { 'vim-pathogen':
    path        => $pathogen_clone_path,
    source      => 'https://github.com/tpope/vim-pathogen.git',
    clone_name  => 'vim-pathogen',
    local_user  => $user,
    github_user => undef,
    identity    => undef,
  }
  -> file { "${vim_path}/autoload/pathogen.vim":
    ensure => 'link',
    source => "${pathogen_clone_path}/vim-pathogen/autoload/pathogen.vim",
  }

  $bundles.each |$bundle| {
    workstation::repo { $bundle['source']:
      path        => "${vim_path}/bundle",
      source      => $bundle['source'],
      clone_name  => $bundle['clone_name'],
      local_user  => $user,
      github_user => undef,
      identity    => undef,
    }
  }
}
