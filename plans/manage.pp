# Ensure puppet is installed, and then ensure the given node
# is managed as a workstation, based on the hieradata configuration.
plan workstation::manage(
  TargetSpec $nodes,
) {
  apply_prep($nodes)

  get_targets($nodes).each |$target| {
    $target_account = lookup(workstation::account)
    out::message("Generating a workstation on ${target} for ${target_account}")

    $results = apply($target, _catch_errors => true) {
      $message = @(WARNING/L)
        This may take several minutes, depending on how many Ruby installations are being downloaded \
        and compiled for this workstation, and how many repositories are being cloned.
        |-WARNING
      warning($message)
      include workstation
    }

    workstation::display_apply_results($results.first())
    return $results
  }
}
