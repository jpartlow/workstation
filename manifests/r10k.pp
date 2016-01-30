# Install r10k gem so that we can manage module dependencies, and not write everything
# from scratch.
class workstation::r10k {
  package { 'r10k':
    provider => 'puppet_gem'
  }
}
