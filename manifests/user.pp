# Class: workstation::user
# ========================
#
# Creates the developer user account on the workstation.
#
# Parameters
# ----------
#
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
