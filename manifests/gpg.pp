class keypair::gpg {

  file { '/etc/gpg_keys':
    ensure => directory,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }

}
