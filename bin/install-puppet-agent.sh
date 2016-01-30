set -x
set -e

if [ -z "$1" ]; then
  echo "Usage: install-puppet-agent.sh <ver>"
  echo "  ver - the puppet-agent release version ('1.3.4' for example)"
  exit 1
fi

agent_version=$1
if [ -e '/etc/lsb-release' ]; then
  platform='debian'
  package_type='deb'
  repo_platform=$(lsb_release -c | sed "{ s/Codename:[ \t]*\([a-z]\+\)/\1/ }")
  repo_config_file='/etc/apt/sources.list.d/puppet-agent.list'
else
  echo "Installing puppet-agent on this platform isn't handled yet."
  exit 1
fi

curl -f -o "${repo_config_file?}" "http://builds.puppetlabs.lan/puppet-agent/${agent_version?}/repo_configs/${package_type?}/pl-puppet-agent-${agent_version?}-${repo_platform?}.list"

case $platform in
  debian)
    apt-get update
    apt-get install --allow-unauthenticated -y puppet-agent
    ;;

  *)
    echo "Platform ${platform?} not handled yet"
    exit 1
    ;;
esac
