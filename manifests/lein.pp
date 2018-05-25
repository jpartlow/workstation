# Class: workstation::lein
#
# Install the lein command line tool for working with Clojure
# projects. Assumes java is already installed. Needs minimum
# of Java 8.
class workstation::lein(
  String $user = $::workstation::user::account
) {
  $homedir = "/home/${user}"
  file { "${homedir}/bin/lein":
    source => 'https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein',
    owner  => $user,
    group  => $user,
    mode   => '0750',
  }
  -> exec { 'Init lein':
    command     => 'lein',
    path        => "/usr/bin:/bin:${homedir}/bin",
    cwd         => $homedir,
    user        => $user,
    environment => "HOME=${homedir}",
  }
}
