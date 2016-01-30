set -x
set -e

# The directory this file is in
bin_dir=$(dirname ${0?})
# The root of the project
project_dir=$(dirname ${bin_dir?})
# The location of the installed puppet-agent's binaries
puppet_bin_dir='/opt/puppetlabs/puppet/bin'
# The local project's modules
modules_dir="${project_dir?}/modules"
# Ephemeral build files
build_dir="${project_dir?}/build"
# Third party modules managed by r10k which the project modules depend on
r10k_modules_dir="${build_dir?}/modules"
# Modulepath needed to locate all required modules
modulepath="${modules_dir?}:${r10k_modules_dir}"

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

"${puppet_bin_dir?}/puppet" apply --modulepath "${modules_dir?}" -e "include 'workstation::r10k'"

"${puppet_bin_dir?}/r10k" puppetfile install --puppetfile "${project_dir?}/Puppetfile" --moduledir "${r10k_modules_dir?}"
