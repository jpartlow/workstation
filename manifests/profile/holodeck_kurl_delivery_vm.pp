# Class: workstation::profile::holodeck_kurl_delivery_vm
# ======================================================
#
# Preps a delivery.puppetlabs.net centos-8.3-kurl-beta-x86_64 (or whatever the
# current flavor is) vm.
#
# * Performs some post checkout system commands to get k8s running.
#
# Parameters:
# -----------
#
class workstation::profile::holodeck_kurl_delivery_vm(
  String $kots_admin_password = 'puppet',
  Integer $timeout = 600,
) {
  file { "/root/kickstart-kurl-abs-vm.sh":
    source => "puppet:///modules/workstation/kickstart-kurl-abs-vm.sh",
    mode   => "0750",
  }
  -> exec { "start containerd and sort out k8s":
    command => "/root/kickstart-kurl-abs-vm.sh ${kots_admin_password}",
    timeout => $timeout,
  }
}
