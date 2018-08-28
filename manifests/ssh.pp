class workstation::ssh(
  Array[Array[String]] $public_keys,
  String $user  = $::workstation::user::account,
  String $sshdir = "/home/${user}/.ssh",
) {
  
  file { $sshdir:
    ensure => 'directory',
    mode   => '0600',
  }

  $public_keys.each |$pub| {
    $comment = $pub[0]
    $key = $pub[1]
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
    ],
    order => '10',
  }
}
