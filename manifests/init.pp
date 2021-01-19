# Class: workstation
# ===========================
#
# Controls baseline setup of a development workstation.
#
# Parameters
# ----------
#
# @param account [String] Account name to ensure is created.
# @param repository_data [Array<Hash>] Of repositories to clone. This is
#   passed to the workstation::repositories class.
# @param ssh_public_keys [Array<String>] Of SSH public keys to
#   authorize for access to the $account on the workstation. (see
#   workstation::ssh::public_keys)
# @param vim_bundles [Array<Hash>] Of vim plugin repository info passed to
#   workstation::vim.
# @param packages [Array<String>] List of packages to install.
#
# Authors
# -------
#
# Josh Partlow <joshua.partlow@puppetlabs.com>
#
class workstation(
  String $account,
  Array[Hash] $repository_data,
  Array[String] $ssh_public_keys,
  Array[Hash] $vim_bundles = [],
  Array[String] $packages = [],
  Workstation::Package_repo_struct $package_repositories = [],
  Boolean $skip_pe_acceptance = true,
){

  class { 'workstation::profile::dev_account_base':
    account                => $account,
    ssh_public_keys        => $ssh_public_keys,
    repository_data        => $repository_data,
    repository_subdir_mode => '0644', # open for NFS traversal
    vim_bundles            => $vim_bundles,
    additional_packages    => $packages,
  }
  contain 'workstation::profile::dev_account_base'

  contain workstation::bin_links

  contain workstation::package_repositories

  contain workstation::known_hosts

  File {
    ensure => directory,
    owner  => $account,
    group  => $account,
  }
  file { "/home/${account}": }
  file { "/home/${account}/bin": }
  file { "/home/${account}/work": }
  file { "/home/${account}/work/tmp": }

  contain workstation::bolt

  class { 'workstation::profile::nfs':
    user => $account,
  }
  contain 'workstation::profile::nfs'

  $_pooler_file_args = {
    ensure => 'present',
    owner  => $account,
    group  => $account,
    mode   => '0600',
  }

  if !$skip_pe_acceptance {
    class { 'workstation::pe_acceptance':
      user => $account,
    }
  }

  # Copying these assumes that the account we are generating on the
  # workstation is the same as the account we are running the plan from...
  workstation::copy_secret_and_link { "/home/${account}/.vmfloaty.yml":
    user => $account,
  }
  # Needed if a Bolt plan for installing PE needs to copy this dev
  # control repo private key for code manager setup onto a PE test host.
  workstation::copy_secret_and_link { "/home/${account}/.ssh/id-control_repo.rsa":
    user            => $account,
    destination     => "/home/${account}/.ssh/id-control_repo.rsa",
    fail_if_missing => false,
  }
}
