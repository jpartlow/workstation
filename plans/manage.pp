# Ensure puppet is installed, and then ensure the given node
# is managed as a workstation, based on the hieradata configuration.
plan workstation::manage(
  TargetSpec $nodes,
) {
  apply_prep($nodes)

  get_targets($nodes).each |$target| {
    apply($target) {
      $target_account = lookup(workstation::account)
      notice("Generating a workstation on ${target} for ${target_account}")
      warning("This may take several minutes, depending on how many Ruby installations are being downloaded and compiled for this workstation, and how many repositories are being cloned.")
      include workstation
    }
  }
}
