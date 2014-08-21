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

  # create directory to hold files to share
  file { $share_path:
    ensure => directory,
    owner  => $share_owner,
    group  => $share_group,
    mode   => $share_mode,
  }

  # we need to add our share to the puppet fileserver
  file { "/etc/puppetlabs/puppet/fileserver.conf":
    ensure  => file,
    content => template("puppet_shared_directory/fileserver.conf.erb"),
    owner   => "root",
    group   => "pe-puppet",
    mode    => "0644",
    notify  => Service["pe-httpd"]
  }

  # ... and we need to add our share to the TOP of auth.conf
  file { "/etc/puppetlabs/puppet/auth.conf":
    ensure  => file,
    content => template("puppet_shared_directory/auth.conf.erb"),
    owner   => "root",
    group   => "root",
    mode    => "0644",
    notify  => Service["pe-httpd"],
  }

  # nice alias in roots homedir 
  file { "/root${share_path}":
    ensure => symlink,
    target => $share_path,
  }


  # take ownership of pe-puppet module (yuk) so that we can restart it for 
  # fileserver. The propper way would be to break this out to another module...
  service { "pe-httpd":
    ensure => running,
    enable => true,
  }
}
