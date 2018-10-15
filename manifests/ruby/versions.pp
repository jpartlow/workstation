# Class: workstation::ruby::versions
# ==================================
#
# Encapsulates installtion of specific Ruby versions and gem sets
# via rbenv::build and rbenv::gem for the purpose of ordering.
#
# Parameters
# ----------
#
# @param ruby_versions [Array<String>] List of Ruby versions to install.
# @param gems [Array<String>] List of gem names to install in each Ruby.
#
class workstation::ruby::versions(
  Array[String] $ruby_versions,
  Array[String] $gems,
) {
  $ruby_versions.each |$index, $version| {

    $global = $index ? {
      0       => true,
      default => false,
    }

    rbenv::build { $version:
      global  => $global,
    }

    $gems.each |$gem_name| {
      rbenv::gem { "${gem_name} on ${version}":
        gem          => $gem_name,
        ruby_version => $version,
      }
    }
  }
}
