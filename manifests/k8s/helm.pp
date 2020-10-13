class workstation::k8s::helm(
  String $version = 'latest',
  Array[
    Struct[{name => String,
            url  => Pattern[/^http.*/]}]] $chart_repos = [],
) {

  # The embedded the version lookup is for the shell
  workstation::install_release_binary { 'helm/helm/helm-v${VERSION}-linux-amd64.tar.gz':
    version      => $version,
    creates      => 'helm',
    install_dir  => '/usr/bin',
    download_url => 'https://get.helm.sh',
    archive_file => 'linux-amd64/helm',
  }

  $chart_repos.each |$repo_info| {
    $name = $repo_info['name']
    $url  = $repo_info['url']

    exec { "add-helm-repo-${name}":
      command => "helm repo add ${name} ${url}",
      path    => $facts['path'],
      unless  => "helm repo list | grep -q '${url}'",
      notify  => Exec['helm-update'],
    }
  }

  exec { 'helm-update':
    command      => 'helm repo update',
    path         => $facts['path'],
    refreshonly => true,
  }
}
