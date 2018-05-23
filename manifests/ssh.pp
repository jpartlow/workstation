class workstation::ssh(
  Array[Array[String]] $public_keys,
  Array[String] $insecure_private_keys = [],
  String $user  = $::workstation::user::account,
  String $sshdir = "/home/${user}/.ssh"
) {
  
  file { $sshdir:
    ensure => 'directory',
    mode   => '0600',
  }

  $public_keys.each |$pub| {
    $comment = $pub[0]
    $key = $pub[1]
    ssh_authorized_key { $comment:
      ensure  => present,
      user    => $user,
      type    => 'ssh-rsa',
      key     => $key,
    }
  }

  $insecure_private_keys.each |$key| {
    file { "${sshdir}/${file}":
      ensure => 'present',
      content => $key,
      mode   => '0600',
    }
  }
}
