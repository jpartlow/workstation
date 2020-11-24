define workstation::make_p(
  String $path = $title,
  Variant[Workstation::Absolute_path,Pattern[/^$/]] $root_prefix = '',
  Optional[String] $user = undef,
  String $mode = '0640',
) {
  if $path =~ Workstation::Absolute_path and !empty($root_prefix) {
    fail("The path '${path}' should not be absolute if a non empty root_prefix ('${root_prefix}') is given")
  }

  $path_elements = $path.split(/\//).reduce([]) |$memo,$dir| {
    empty($dir) ? {
      true    => $memo,
      default => $memo + $dir,
    }
  }

  $subdirs = $path_elements.map |$index,$_dir| {
    ([$root_prefix] + $path_elements[0,$index + 1]).join('/')
  }

  $file_params = empty($user) ? {
    false   => { 'owner' => $user },
    default => {},
  }.merge({ mode => $mode })

  $subdirs.each |$dir| {
    if !defined(File[$dir]) {
      file { $dir:
        ensure => 'directory',
        *      => $file_params,
      }
    }
  }
}
