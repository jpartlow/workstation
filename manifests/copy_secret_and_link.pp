# Define: workstation::copy_secret_and_link
# =========================================
#
# Copy a file from the controller workstation to a dev host
# user's home and optionally create symlinks to it on the devhost.
#
# Used for copying files that we don't want to check in
# but need a local copy of on the dev host we're building.
#
# Parameters:
# -----------
#
# @param local_file
#   The absolute path to the local file we are going to copy over.
# @param user
#   The user on the dev host we're copying to (file is copied to /home/$user)
# @param destination
#   Optional path to the destination file on the target host. If skipped,
#   will be placed in the user home dir.
# @param mode
#   Permissions to set for the file.
# @param links
#   An optional array of symbolic link paths to generate on the dev host.
define workstation::copy_secret_and_link(
  String $user,
  Workstation::Absolute_path $local_file = $title,
  Optional[Workstation::Absolute_path] $destination = undef,
  Pattern[/0\d\d\d/] $mode = '0600',
  Array[Workstation::Absolute_path] $links = [],
) {
  $filename = $local_file.split(/\//)[-1]
  $dev_host_file = pick($destination, "/home/${user}/${filename}")
  file { $dev_host_file:
    ensure  => 'present',
    content => file($local_file),
    mode    => $mode,
    owner   => $user,
    group   => $user,
  }

  $links.each |$link| {
    file { $link:
      ensure => 'link',
      target => $dev_host_file,
    }
  }
}
