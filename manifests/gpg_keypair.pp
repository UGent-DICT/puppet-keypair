define keypair::gpg_keypair (
  $basename,
  $uid = nil,
) {

  include gpg # To make the parent directory

  $existing_key = gpg_find_key($::gpg_keys, {
      'secret_present' => true,
      'basename'       => $basename,
    })

  $filename = "/etc/gpg_keys/${basename}"

  if $existing_key {
    $key = $existing_key

    file { "${filename}.sec":
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0400',
      content => undef,
    }

  } else {
    # Generate a key
    $generated_key = gpg_generate_key({
        'uid' => $uid,
      })
    $key = $generated_key

    file { "${filename}.sec":
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0400',
      content => $generated_key['secret_key'],
    }
  }

  file { "${filename}.pub":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => $key['public_key'],
  }

}
