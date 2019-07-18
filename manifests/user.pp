# Class: workstation::user
# ========================
#
# Creates the developer user account on the workstation.
#
# Parameters
# ----------
#
# @param account [String] Account name to ensure is created.
# @param groups [Array<String>] Of groups the account should belong to.  Default is 'sudo'.
class workstation::user(
  String $account,
  String $shell = '/bin/bash',
  Optional[Array[String]] $groups = undef,
) {

  $default_groups = case $facts['os']['family'] {
    'RedHat': { [ 'adm', 'wheel'] }
    default: { ['sudo', 'admin'] }
  }

  $_groups = $groups =~ Undef ? {
    true    => $default_groups,
    default => $groups,
  }

  user { $account:
    ensure     => present,
    managehome => true,
    groups     => $_groups,
    shell      => $shell,
  }
}
