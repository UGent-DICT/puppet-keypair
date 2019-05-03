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
