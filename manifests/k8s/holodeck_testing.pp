# Class: workstation::k8s::holodeck_testing
# =========================================
#
# These are additional tools and package dependencies
# required to run the holodeck-manifests unit and
# integration tests.
class workstation::k8s::holodeck_testing(
  String $dev_user,
) {
  # This is a configuration testing tool used by holodeck-manifests unit tests
  # to validate container configurations.
  workstation::install_release_binary { 'open-policy-agent/conftest/conftest_${VERSION}_Linux_x86_64.tar.gz':
    creates => 'conftest',
  }

  # This installs yarn, a nodejs package manager used by the PipelinesInfra
  # repo which holodeck-manifest's Makefile relies on for integration testing
  # of cd4pe.
  class { 'workstation::yarn':
    user => $dev_user,
  }
  contain 'workstation::yarn'

  # The PipelinesInfra test suite uses puppeteer, which expects a
  # chromium-headless environment with the following dependencies to execute
  # under Linux. These are the centos deps (and assume epel repo is set up):
  $puppeteer_chromium_headless_packages = [
    'chromium-headless',
    'alsa-lib.x86_64',
    'atk.x86_64',
    'cups-libs.x86_64',
    'gtk3.x86_64',
    'ipa-gothic-fonts',
    'libXcomposite.x86_64',
    'libXcursor.x86_64',
    'libXdamage.x86_64',
    'libXext.x86_64',
    'libXi.x86_64',
    'libXrandr.x86_64',
    'libXScrnSaver.x86_64',
    'libXtst.x86_64',
    'pango.x86_64',
    'xorg-x11-fonts-100dpi',
    'xorg-x11-fonts-75dpi',
    'xorg-x11-fonts-cyrillic',
    'xorg-x11-fonts-misc',
    'xorg-x11-fonts-Type1',
    'xorg-x11-utils',
  ]

  package { $puppeteer_chromium_headless_packages:
    ensure => 'latest',
  }
}
