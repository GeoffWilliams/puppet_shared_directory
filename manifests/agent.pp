# copy files from the puppet master to a directory on an agent
class puppet_shared_directory::agent(
    $target_dir  = "/root/extra_files",
    $mount_point = "shared"
  ) {

  $pfs_uri = "puppet:///${mount_point}/"

  file { $target_dir:
    recurse => remote,
    source  => $pfs_uri,
  }
}
