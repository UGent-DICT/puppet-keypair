define keypair::x509_keypair () {

  $existing_key = keypair::get_first_matching_value($::x509_keys, {
      'secret_present' => true,
      'basename'       => $name,
    })

  $filename = "/etc/ssl/private/${name}"

  if $existing_key {
    $key = $existing_key

    file { "${filename}.key":
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0400',
      content => undef,
    }

  } else {
    # Generate a key
    $generated_key = x509_generate_key({
        'CN' => $name,
      })
    $key = $generated_key

    file { "${filename}.key":
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0400',
      content => $generated_key['secret_key'],
    }
  }

  file { "${filename}.crt":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => $key['cert'],
  }

}
