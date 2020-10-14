# Define: workstation::bash_installer
# ===================================
#
# Wraps handling general install via curl | bash oneliners
# that install a single binary.
#
# Will also ensure the installed file is 0755 root:root unless
# told otherwise.
#
# Parameters
# ----------
# 
# @param url
#   The url to curl the installer script from.
# @param creates
#   The full path to the binary the installer installs.
# @param owner
#   Some scripts are sloppy about ensuring owner, and leave behind tar
#   owner/group #s.
# @param owner
#   Some scripts are sloppy about ensuring group
# @param owner
#   Some scripts are sloppy about ensuring mode.
define workstation::bash_installer(
  Pattern[/^https:/] $url,
  Workstation::Absolute_path $creates,
  String $owner = 'root',
  String $group = 'root',
  String $mode  = '0755',
) {
  $installer = "curl -sSL ${url} | bash"

  exec { "install ${creates}":
    command => $installer,
    path    => $facts['path'],
    creates => $creates,
  }

  # Installer script is leaving owner/group from tarball
  file { $creates:
    owner => 'root',
    group => 'root',
    mode  => '0755',
  }
}
