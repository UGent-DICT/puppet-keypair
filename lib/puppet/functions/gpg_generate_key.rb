# The gpg_generate_key function generates a new RSA GPG keypair.
Puppet::Functions.create_function(:gpg_generate_key) do
  dispatch :gpg_generate_key_defaults do
  end

  dispatch :gpg_generate_key_length do
    param 'Integer[0]', :key_length
  end

  dispatch :gpg_generate_key_uid do
    param 'String', :uid
  end

  dispatch :gpg_generate_key do
    param 'Integer[0]', :key_length
    param 'String', :uid
  end

  # @param options Hash with key_length and/or uid keyset.
  dispatch :gpg_generate_key_with_options do
    required_param 'Hash', :options
  end

  def default_key_length
    2048
  end
  private :default_key_length

  def default_uid
    'Auto-generated key'
  end
  private :default_uid

  def gpg_generate_key_defaults
    gpg_generate_key
  end

  def gpg_generate_key_uid(uid)
    gpg_generate_key(default_key_length, uid)
  end

  def gpg_generate_key_length(key_length)
    gpg_generate_key(key_length, default_uid)
  end

  def gpg_generate_key_with_options(options = {})
    key_length = options.fetch('key_length', default_key_length)
    uid = options.fetch('uid', default_uid)
    gpg_generate_key(key_length, uid)
  end

  def gpg_generate_key(key_length = default_key_length, uid = default_uid)
    # Store our input parameters in the result output hash
    output = { params: { key_length: key_length, uid: uid } }

    Dir.mktmpdir do |dir|
      IO.popen(['gpg', '--homedir', dir, '--batch', '--gen-key'], 'r+') do |gpg|
        gpg.puts([
                   '%no-protection',
                   'Key-Type: RSA',
                   'Key-Length: ' + key_length.to_s,
                   'Key-Usage: sign',
                   'Name-Real: ' + uid,
                 ])
      end
      raise Puppet::ParseError, 'Could not generate GPG key' unless $CHILD_STATUS.success?
      IO.popen(
        ['gpg', '--homedir', dir, '--list-keys', '--with-fingerprint',
         '--with-colons', '--fixed-list-mode'],
      ) do |gpg|
        gpg.readlines.each do |line|
          # We just generated a single key in a new directory
          # so we don't need to track which uid belongs to which public key
          if line =~ %r{^pub:[^:]*:(\d+):(\d+):([0-9a-fA-F]+)}
            output['key_length'] = Regexp.last_match(1).to_i
            output['algo'] = Regexp.last_match(2).to_i
            output['keyid'] = Regexp.last_match(3)
          elsif line =~ %r{^fpr:::::::::([0-9a-fA-F]+)}
            output['fingerprint'] = Regexp.last_match(1)
          elsif line =~ %r{^uid:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:([^:]*):}
            output['uid'] = Regexp.last_match(1).clone.gsub(%r{((?:\\[0-9a-fA-F]{2})+)}) do |m|
              [m.delete('\\')].pack('H*')
            end.force_encoding('UTF-8')
          end
        end
      end

      IO.popen(['gpg', '--homedir', dir, '--armour', '--export', output['keyid']]) do |gpg|
        output['public_key'] = gpg.read
      end

      IO.popen(['gpg', '--homedir', dir, '--armour', '--export-secret-key', output['keyid']]) do |gpg|
        output['secret_key'] = gpg.read
      end
    end
    output
  end # mktmpdir
end
