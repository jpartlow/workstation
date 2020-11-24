# Class: workstation::pe_acceptance
# =================================
#
# Setup frankenbuilder and copy key files needed for running
# pe_acceptance_tests via beaker.
class workstation::pe_acceptance(
  String $user,
  String $path = 'work/src/alternates',
) {
  class { 'workstation::frankenbuilder':
    user => $user,
    path => $path,
  }
  contain 'workstation::frankenbuilder'

  workstation::copy_secret_and_link { "/home/${user}/.fog":
    user => $user,
  }

  # Copying over the QE acceptance SSH private key
  # Although in general I'm relying on Agent forwarding, there are some
  # Beaker acceptance tests which assume they can copy this key from the
  # test runner to the SUTs (opsworks for example)
  workstation::copy_secret_and_link { "/home/${user}/.ssh/id_rsa-acceptance":
    user        => $user,
    destination => "/home/${user}/.ssh/id_rsa-jenkins",
  }
}
