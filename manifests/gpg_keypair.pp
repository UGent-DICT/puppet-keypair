# @summary Generate a gpg keypair (private + public key)
#
# The generated keypair will be placed in /etc/gpg_keys/
#
# @param basename Base name of the key. This is only used as
#   the filename for the stored key.
# @param uid Specify the uid to use for the gpg key. This is
#   not the same as the keyid which will be generated but rather
#   the human readable name/description of your key.
define keypair::gpg_keypair (
  $basename,
  $uid = nil,
) {

  include keypair::gpg # To make the parent directory

  $keydir = keypair::gpg_keydir()

  $existing_key = keypair::get_first_matching_value($::gpg_keys, {
      'secret_present' => true,
      'basename'       => $basename,
    })

  $filename = "${keydir}/${basename}"

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
