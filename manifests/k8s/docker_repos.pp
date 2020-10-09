# Define: workstation::k8s::docker_repos
# ======================================
#
# Construct one set of yum docker repos for a given channel.
#
# Parameters
# ----------
#
# @param channel
#   Which channel to configure (stable, test, nightly).
# @param enabled
#   Whether to enable it.
# @param enable_debuginfo
#   If enabled, whether to enable debug packages.
# @param enable_source
#   If enabled, whether to enable source packages.
define workstation::k8s::docker_repos(
  String $channel,
  Boolean $enabled,
  Boolean $enable_debuginfo = false,
  Boolean $enable_source = false,
) {
  $docker_repo_common = {
    ensure   => 'present',
    gpgcheck => 1,
    gpgkey   => 'https://download.docker.com/linux/centos/gpg',
  }
  $capitalized = $channel.capitalize()

  $channel_enabled = $enabled ? {
    true    => 1,
    default => 0,
  }
  $debug_enabled = ($enabled and $enable_debuginfo) ? {
    true    => 1,
    default => 0,
  }
  $source_enabled = ($enabled and $enable_source) ? {
    true    => 1,
    default => 0,
  }

  yumrepo { "docker-ce-${channel}":
    descr   => "Docker CE ${capitalized} - \$basearch",
    baseurl => "https://download.docker.com/linux/centos/\$releasever/\$basearch/${channel}",
    enabled => $channel_enabled,
    *       => $docker_repo_common,
  }

  yumrepo { "docker-ce-${channel}-debuginfo":
    descr   => "Docker CE ${capitalized} - Debuginfo \$basearch",
    baseurl => "https://download.docker.com/linux/centos/\$releasever/debug-\$basearch/${channel}",
    enabled => $debug_enabled,
    *       => $docker_repo_common,
  }

  yumrepo { "docker-ce-${channel}-source":
    descr   => "Docker CE ${capitalized} - Sources",
    baseurl => "https://download.docker.com/linux/centos/\$releasever/source/${channel}",
    enabled => $source_enabled,
    *       => $docker_repo_common,
  }
}
