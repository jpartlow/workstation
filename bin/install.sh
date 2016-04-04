set -e

# The directory this file is in
bin_dir=$(dirname "${0?}")
# The root of the project
project_dir=$(dirname "${bin_dir?}")
# Ephemeral build files
pkg_dir="${project_dir?}/pkg"
# The location of the installed puppet-agent's binaries
puppet_bin_dir='/opt/puppetlabs/puppet/bin'
# Where to install modules to so we can apply them
modules_dir="/opt/puppetlabs/workstation-modules"

usage() {
  message=$1

  if [ -n "$message" ]; then
    echo "!! ${message}"
  fi
  echo "Usage: install.sh -a <puppet-agent-ver> [-h <user@host>] [-i <ssh-key>]"
  echo "  -a <puppet-agent-ver> - the puppet-agent release version ('1.3.4' for example)"
  echo "  -h <user@host> - if provided ssh to this host before attempting install"
  echo "     (module will be scp'd first)"
  echo "  -i <ssh-key> - if needed for reaching host"
  echo "  -y - do not prompt"
  echo "  -d - run with debug output (set -x trace)"
  echo "  -? - this help message"
  exit 1
}

build() {
  local puppet="${1?}"

  rm -f "${pkg_dir}/*" >/dev/null 2>&1
  module=$(${puppet?} module --confdir ./.puppetlabs build "${project_dir?}" | grep 'Module built:' | grep -Eo '/.*$')
  echo "${module?}"
}

ask() {
  local question="${1?}"
  if [ "${ASSUME_YES}" != 'true' ]; then
    echo "${question?} (y/N)"
    read answer
    if [ "${answer}" != 'y' -a "${answer}" != "Y" ]; then
      usage
    fi
  fi
}

install_agent() {
  ask "* This will install puppet-agent version ${AGENT_VERSION?} locally.  Is that what you want?"

  if [ -e '/etc/lsb-release' ]; then
    local platform='debian'
    local package_type='deb'
    local repo_platform=$(lsb_release -c | sed "{ s/Codename:[ \t]*\([a-z]\+\)/\1/ }")
    local repo_config_file='/etc/apt/sources.list.d/puppet-agent.list'
  else
    echo "!! Installing puppet-agent on this platform isn't handled yet."
    exit 1
  fi

  curl -f -o "${repo_config_file?}" "http://builds.delivery.puppetlabs.net/puppet-agent/${AGENT_VERSION?}/repo_configs/${package_type?}/pl-puppet-agent-${AGENT_VERSION?}-${repo_platform?}.list"

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

  local module=$(build "${puppet_bin_dir?}/puppet")

  rm -rf "${modules_dir?}"
  "${puppet_bin_dir?}/puppet" module install --target-dir "${modules_dir}" "${module?}"
}

apply_workstation() {
  ask "This will apply the workstation manifests to this local machine, installing rbenv, cloning repositories and configuring for a workstion environment.  Is this what you what?"

  if [ "${IS_DEBUG}" = 'true' ]; then
    local debug_arg="--debug"
  fi
  "${puppet_bin_dir?}/puppet" apply "${debug_arg}" --modulepath "${modules_dir?}" -e 'include workstation'
}

scp_file() {
  local file="${1?}"
  scp "${file?}" "${USER_HOST?}:" ${IDENTITY_ARG}
}

bootstrap_remote() {
  local module="${1?}"

  local module_file=$(basename "${module?}")
  local module_dir="${module_file%%.tar.gz}"
  if [ "${IS_DEBUG}" = 'true' ]; then
    local debug_arg="-d"
  fi

  cat >"${pkg_dir?}/unpack_and_invoke.sh" <<-script
cp ${module_file?} /root/
cd /root
tar -xzf ${module_file?}
cd ${module_dir?}
bin/install.sh -a ${AGENT_VERSION?} -y ${debug_arg}
script

  scp_file "${pkg_dir?}/unpack_and_invoke.sh"
  ssh "${USER_HOST?}" ${IDENTITY_ARG} sudo bash unpack_and_invoke.sh
}

while getopts a:h:i:dy? name; do
  case "$name" in
    \?)
        usage
        ;;
    d)
        IS_DEBUG='true'
        set -x
        ;;
    a)
        AGENT_VERSION="${OPTARG?}"
        ;;
    h)
        USER_HOST="${OPTARG?}"
        ;;
    i)
        identity="${OPTARG?}"
        if [ -n "${identity}" ]; then
          IDENTITY_ARG="-i ${identity}"
        else
          IDENTITY_ARG=""
        fi
        ;;
    y)
        ASSUME_YES='true'
        ;;
  esac
done

if [ -z "$AGENT_VERSION" ]; then
  usage "You must specify an agent version."
elif [ -n "$USER_HOST" ]; then
  module=$(build "bundle exec puppet")
  scp_file "${module?}"
  bootstrap_remote "${module?}"
else
  install_agent
  apply_workstation
fi
