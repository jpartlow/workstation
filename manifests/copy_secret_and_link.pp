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
# @param links
#   An optional array of symbolic link paths to generate on the dev host.
define workstation::copy_secret_and_link(
  Workstation::Absolute_path $local_file,
  String $user,
  Array[Workstation::Absolute_path] $links = [],
) {
  $filename = $local_file.split(/\//)[-1]
  $dev_host_file = "/home/${user}/${filename}"
  file { $dev_host_file:
    ensure  => 'present',
    content => file($local_file),
    mode    => '0640',
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
