#! /opt/puppetlabs/puppet/bin/ruby

require 'open3'
require 'json'
require 'pp'

class GetK8sVersions
  def self.run
    docker_command = %q{rpm -qa 'docker*'}
    docker, _status = Open3.capture2e(docker_command)
    k8s_command = %q{rpm -qa 'kube*'}
    k8s, _status = Open3.capture2e(k8s_command)
    kots_command = %q{kubectl kots version}
    kots, _status = Open3.capture2e(kots_command)
    replicated_command = %q{replicated version}
    repl, _status = Open3.capture2e(replicated_command)
    replicated = JSON.parse(repl)
    kind_command = %q{kind version}
    kind, _status = Open3.capture2e(kind_command)
    helm_command = %q{helm version}
    helm, _status = Open3.capture2e(helm_command)
    h_ver = helm.split('version.BuildInfo').last 
    h_json = h_ver.gsub(/(\w+):/,%q{"\1":})
    helm_parsed = JSON.parse(h_json)

    versions = {
      docker_command     => docker.split("\n"),
      k8s_command        => k8s.split("\n"),
      kots_command       => kots.split("\n"),
      replicated_command => replicated,
      kind_command       => kind,
      helm_command       => helm_parsed,
    }.to_json

    print versions
  end
end

GetK8sVersions.run
