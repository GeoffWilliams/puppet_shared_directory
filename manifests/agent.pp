# copy files from the puppet master to a directory on an agent
class puppet_shared_directory::agent(
    $target_dir  = "/root/extra_files",
    $mount_point = "extra_files"
  ) {

  $pfs_uri = "puppet:///${mount_point}"

  file { $target_dir:
    ensure  => directory,
    recurse => remote,
    source  => $pfs_uri,
  }
}
