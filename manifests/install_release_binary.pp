# Define: workstation::install_release_binary
# ===========================================
#
# Captures a repeated step of downloading and installing a particular binary
# from a github project's releases page. Essentially interacting with:
#
#   https://github.com/${organization}/${project}/releases/download/v{$version}/${package}
#
# If the package is a tarball (based on ext) will be untarred).
#
# This type is expecting that what we download or untar is a single binary to
# be placed in $install_dir as "${install_dir}/${creates}.
#
# Parameters
# ----------
#
# @param organization
#   The github organization.
# @param project
#   The github project.
# @param package
#   The name of the package to download from release.
# @param skip_release_download_project_dir
#   Set false to add a project subdir in between the download and version
#   directory of the download url.
# @param version
#   The exact version to download. If 'latest' will lookup latest version.
# @param creates
#   The name of the binary command to install (may be different from the name
#   of the package we are downloading).
# @param install_dir
#   The absolute path to the directory we are installing the binary into.
# @param download_url
#   If the project helpfully provides a completely different url for
#   downloading the binaries, it can be hacked in here.
# @param archive_file
#   The specific file from the archive to install. If not set, assumes
#   a simple archive that just untars to a single $creates file.
# @param owner
#   The user that should own the installed binary.
# @param version_prefix
#   Some projects helpfully have a 'v' in front of their versions.
#   Others do not. yay
define workstation::install_release_binary(
  String $organization = $title.split(/\//)[0],
  String $project = $title.split(/\//)[1],
  String $package = $title.split(/\//)[2],
  Boolean $skip_release_download_project_dir = true,
  String $version = 'latest',
  String $creates = $package,
  Workstation::Absolute_path $install_dir = '/usr/local/bin',
  Optional[String] $download_url = undef,
  Optional[String] $archive_file = undef,
  String $owner = 'root',
  String $version_prefix = 'v',
) {
  if $version == 'latest' {
    $version_lookup = "VERSION=$(curl -sSL -o /dev/null --write-out '%{url_effective}' https://github.com/${organization}/${project}/releases/latest | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+')"
  } else {
    $version_lookup = "VERSION=${version}"
  }

  if empty($download_url) {
    $project_dir = $skip_release_download_project_dir ? {
      false   => "${project}/",
      default => '',
    }
    $download = "curl -fsSL -O \"https://github.com/${organization}/${project}/releases/download/${project_dir}${version_prefix}\${VERSION}/${package}\""
  } else {
    $download = "curl -fsSL -O \"${download_url}/${package}\""
  }

  if $package =~ /(tar.gz|tar|tgz)$/ {
    $untar = "tar -xf ${package}"
    $binary = pick($archive_file, $creates)
  } else {
    $untar = undef
    $binary = $package
  }

  $chown = "chown ${owner}:${owner} ${binary}"
  $chmod = "chmod 0755 ${binary}"
  $move = "mv ${binary} ${install_dir}/${creates}"

  $installer_cmds = [
    "cd $(mktemp -d)",
    $version_lookup,
    $download,
    $untar,
    $chown,
    $chmod,
    $move,
  ] - [ undef ]

  $installer = $installer_cmds.join(' && ')

  exec { "install-${creates}":
    command => $installer,
    path    => $facts['path'],
    creates => "${install_dir}/${creates}",
  }
}
