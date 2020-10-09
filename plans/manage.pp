# Ensure puppet is installed, and then ensure the given node
# is managed as a workstation, based on the hieradata configuration.
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

    $results = apply($target, _catch_errors => true) {
      $profiles = lookup('workstation::profiles', 'default_value' => [])
      if empty($profiles) {
        fail("No 'profiles' found in data/nodes/${target.facts['clientcert']}.yaml. Nothing to apply.")
      }
      $profiles.each |$p| {
        contain $p
      }
    }

    workstation::display_apply_results($results.first())
    return $results
  }
}
