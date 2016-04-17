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
  Array[String] $groups = ['sudo'],
) {

  user { $account:
    ensure     => present,
    managehome => true,
    groups     => $groups,
  }
}
