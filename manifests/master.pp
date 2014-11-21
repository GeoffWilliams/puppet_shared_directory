# setup the puppet master to share a directory of files via its puppet master
# file server
#
# Creates a directory on puppetmaster and replaces the puppet default 
# fileserver.conf file.
#
# Only works with puppet enterprise for now
class puppet_shared_directory::master(
    $mount_point = "extra_files",
    $share_path  = "/shared",
    $share_hosts = "*",
    $share_owner = "root",
    $share_group = "root",
    $share_mode  = "0755",
) {

  $fileserver = '/etc/puppetlabs/puppet/fileserver.conf'
  
  # create directory to hold files to share
  file { $share_path:
    ensure => directory,
    owner  => $share_owner,
    group  => $share_group,
    mode   => $share_mode,
  }

  # use augeas to change fileserver.conf to prevent ownership conflict
  # between this module and PE
  augeas { "fileserver.conf ${mount_point}":
    changes   => [
      "set /files/${fileserver}/${mount_point}/path ${share_path}",
      "set /files/${fileserver}/${mount_point}/allow ${share_hosts}",
    ],
    incl      => $fileserver,
    load_path => '/opt/puppet/share/augeas/lenses/dist',
    lens      => 'PuppetFileserver.lns',
    notify  => Service["pe-puppetserver"]
  }



  # nice alias in roots homedir 
  file { "/root${share_path}":
    ensure => symlink,
    target => $share_path,
  }

}
