plan workstation::install_k8s(
  TargetSpec $targets,
) {
  apply_prep($targets)

  get_targets($targets).each |$target| {
    out::message("Installing docker, k8s and tools on ${target}")

    $result = apply($target, _catch_errors => true) {
      include 'workstation::k8s'
    }

    workstation::display_apply_results($result.first())
    return $result
  }
}
