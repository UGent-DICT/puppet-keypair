# @summary Small wrapper to manage /etc/gpg_keys or not.
#
# @param manage_dir If true, will create the file /etc/gpg_keys resource.
class keypair::gpg (
  Boolean $manage_dir = true,
) {
  if $manage_dir {
    file { '/etc/gpg_keys':
      ensure => directory,
      mode   => '0755',
      owner  => 'root',
      group  => 'root',
    }
  }
}
