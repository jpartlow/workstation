# Class: workstation::ruby::dependencies
#
# The rbenv module includes dependencies automatically, but they are out of
# date for Ubuntu 18.04. This class provides a fresher list.
#
# Parameters
# ----------
#
# @param ubuntu_18 [Boolean] If true require packages for Ubuntu 18.04+,
#   otherwise do nothing.
class workstation::ruby::dependencies(
  Boolean $ubuntu_18 = false,
) {
  # updated package list for 18.04
  if $ubuntu_18 {
    ensure_packages([
      'build-essential',
      'git',
      'libreadline-dev',
      'libssl-dev',
      'zlib1g-dev',
      'libffi-dev',
      'libyaml-dev',
      'libncurses5-dev',
      # there was a libgdbm3 here, but libgdbm3 doesn't exist in 18.04, and
      # libgdbm5 seems to be installed as dep of libgdbm-dev
      'libgdbm-dev',
      'patch'
    ])
  }
}
