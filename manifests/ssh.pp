# Class: workstation::ssh
# =======================
#
# Ensures sane permissions on the user account's .ssh dir and adds any
# passed public keys to the authorized_keys file.
#
# Expects to be able to find and read the passed public keys from the
# the local .ssh directory.
#
# Parameters
# ----------
#
# @param public_keys [Array[String]] Array of public keys found in the local .ssh dir to
#   be copied to the remote .ssh/authorized_keys file.
# @param user [String] The user account to manage.
# @param sshdir [String] The path to the .ssh dir on the remote machine (also the path
#   used locally to read the public key contents).
class workstation::ssh(
  Array[String] $public_keys,
  String $user  = $::workstation::user::account,
  String $sshdir = "/home/${user}/.ssh",
) {

  file { $sshdir:
    ensure => 'directory',
    owner  => $user,
    mode   => '0600',
  }

  $public_keys.each |$pub| {
    $comment = $pub
    $key = strip(file("${sshdir}/${pub}").split(' ')[1])
    ssh_authorized_key { $comment:
      ensure => present,
      user   => $user,
      type   => 'ssh-rsa',
      key    => $key,
    }
  }

  Ssh::Config_entry {
    ensure => present,
    path   => "${sshdir}/config",
    owner  => $user,
    group  => $user,
  }

  ssh::config_entry { 'pooler hosts':
    host  => '10.16.* 10.18.* *.delivery.puppetlabs.net',
    lines => [
      '  StrictHostKeyChecking=no',
      '  UserKnownHostsFile=/dev/null',
      '  ForwardAgent=yes',
    ],
    order => '10',
  }
}
