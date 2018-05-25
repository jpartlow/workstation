# Class: workstation::packages
#
# Simplifies specifying dependencies on packages in general.
class workstation::packages(
  Array[String] $packages = $::workstation::packages,
) {
  package { $packages:
    ensure => latest,
  }
}
