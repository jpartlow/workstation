function workstation::display_apply_results(
  Variant[Result,ApplyResult] $result,
) {
  out::message("Logs from: ${result.target}")

  # Bolt gives us a Result if compilation fails, as apposed to an
  # ApplyResult after the catalog is applied and there's an expectation of
  # a Puppet report being returned.
  case $result {
    ApplyResult: {
      $report = $result.report()
      if $report['logs'] =~ NotUndef {
        $logs = $report['logs']
      } else {
        $logs = []
        warning("The apply on '${result.target()}' did not return a report with logs")
      }
    }
    default: { $logs = [] }
  }

  $logs.each() |$log| {
    $message = "${log['source']}: ${log['message']}"
    case $log['level'] {
      'notice': {
        out::message($message)
      }
      'warning': {
        out::message("WARNING: ${message}")
      }
      'err': {
        out::message("ERROR: ${message}")
      }
      default: {
        # skip info/debug
      }
    }
  }
}
