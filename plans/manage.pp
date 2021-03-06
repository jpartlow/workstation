# Ensure puppet is installed, and then ensure the given node
# is managed as a workstation, based on the hieradata configuration.
#
# Assumes data/nodes contains a hiera yaml file with configuration
# for a particular host in the passed targets.
#
# So if running `bolt plan workstation::manage nodes=some.workstation.net`
# there should be configuration in data/nodes/some.workstation.net.yaml.
#
# At a minimum, there must be a 'workstation::profiles' array with a set
# of classes to be applied.
#
# @param nodes [TargetSpec] nodes to manage.
plan workstation::manage(
  TargetSpec $nodes,
) {
  apply_prep($nodes)

  get_targets($nodes).each |$target| {
    out::message("Generating a workstation on ${target}")
    out::message(" * Will configure ${target} based on hiera data found for data/nodes/${target.facts['clientcert']}.yaml")
    $message = @(WARNING/L)
       * This may take several minutes, depending on how many Ruby installations \
      are being downloaded and compiled for this workstation, and how many \
      repositories are being cloned.
      |-WARNING
    out::message($message)

    # Our hiera.yaml interpolates the host certname fact and can only be looked up
    # correctly within an apply. But we want to lookup the profiles to be applied
    # separately so we can apply them in a sequence and not worry about resource
    # ordering or duplicate resources between profiles.
    #
    # So write out the facts locally and use the local puppet lookup utility to
    # obtain the profile list as an array before we begin applying.
    file::write("/tmp/${target.name}-facts.json", "${to_json_pretty($target.facts())}")
    $local_user = system::env('USER')
    $hiera_command = "/opt/puppetlabs/bolt/bin/puppet lookup --hiera_config ${workstation::project_root()}/hiera.yaml --facts /tmp/${target.name}-facts.json --render-as json workstation::profiles"
    $result = run_command(
      $hiera_command,
      'localhost',
      'run_as'        => $local_user,
      '_catch_errors' => true,
    ).first()
    if !$result.ok() {
      out::message("${result.error()}")
    }
    $result_json = $result['stdout'].strip
    $profiles = empty($result_json) ? {
      true    => [],
      default => parsejson($result_json),
    }

    if empty($profiles) {
      fail("No 'profiles' found in data/nodes/${target.facts['clientcert']}.yaml. Nothing to apply.")
    }
    out::message("Found the following profiles to apply for ${target}: ${profiles}")

    $profiles.each() |$class| {
      out::message(" * Applying ${class}")

      $result = apply($target, _catch_errors => true) {
        include $class
      }.first()

      workstation::display_apply_results($result)
    }
  }
}
