# Class: workstation::bin_links
#
# Ensures a set of ~/bin/ links for puppet binaries that we want to execute
# from the installed packages but which may be also installed as gems via
# bundler.
#
# Many test suites install puppet, facter, hiera in order to be able to test
# manifests, and some may install bolt to tests tasks/plans.
# It's desirable to have the gems in the bundled path for testing, 
# and if bundler is installing gems globally, then rbenv will have setup shims
# for executables in the gems that will take precedence over /usr/local/bin or
# /opt/puppetlabs/bin depending on how $PATH is set up.
#
# Since I have ~/bin at the front of my path, I can intercept calls for
# this executables by linking ~/bin/puppet to /opt/puppetlabs/bin/puppet for
# example.
#
# Parameters
# ----------
#
# @param account [String] Account we are building.
# @param packages [Array<String] List of packages being installed, used to
#   check for which binary links to set.
class workstation::bin_links(
  String $account = $::workstation::account,
  Array[String] $packages = $::workstation::packages,
) {
  [
    'puppet',
    'facter',
    'hiera',
    'bolt',
  ].each |$e| {
    if ($e == bolt) {
      $installing_bolt = $packages.any |$i| { $i == 'puppet-bolt' }
      if !$installing_bolt {
        next()
      }
    }
    file { "/home/${account}/bin/${e}":
      ensure => link,
      target => "/opt/puppetlabs/bin/${e}",
    }
  }
}
