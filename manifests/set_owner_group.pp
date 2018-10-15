# Defined Type: workstation::set_owner_group
# ==========================================
#
# Ensure all files within a target directory have the given owner and group, without running
# afoul of duplicate file resources. Shells out to file | chmod...
#
# Parameters
# ----------
#
# @param owner [String] the user account that should own files.
# @param group [String] the group account to set.
# @param target_directory [String] the directory to recursively set owner and group in.
#
define workstation::set_owner_group(
  String $owner,
  String $group,
  String $target_dir = $title,
){
  exec { "Set user/group of ${target_dir} contents to ${owner}:${group}":
    command => "find ${target_dir}/ \\( ! -user ${owner} -or ! -group ${group} \\) -exec chown ${owner}:${group} -c {} \\;",
    onlyif  => "find ${target_dir}/ \\( ! -user ${owner} -or ! -group ${group} \\) | grep '.*'",
    path    => '/usr/bin:/usr/bin/local:/bin',
  }
}
