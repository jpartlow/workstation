class workstation::packages {
  package { 'vim':
    ensure => latest,
  }
  package { 'tree':
    ensure => latest,
  }
  package { 'python':
    ensure => latest,
  }
  package { 'rsync':
    ensure => latest,
  }
  package { 'curl':
    ensure => latest,
  }
  package { 'wget':
    ensure => latest,
  }
}
