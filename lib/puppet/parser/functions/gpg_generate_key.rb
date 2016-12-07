# rubocop:disable Metrics/BlockLength
module Puppet
  module Parser
    module Functions
      newfunction(:gpg_generate_key, type: :rvalue, doc: <<-EODOC
            The gpg_generate_key function generates a new RSA GPG keypair.
            Optional parameters:
            * key_length
            * uid
        EODOC
      ) do |args|

        params = args.shift || {}

        output = { params: params }

        Dir.mktmpdir do |dir|
          IO.popen(['gpg', '--homedir', dir, '--batch', '--gen-key'], 'r+') do |gpg|
            gpg.puts(
              [
                'Key-Type: RSA',
                'Key-Length: ' + (params['key_length'] || 2048).to_s,
                'Key-Usage: sign',
                'Name-Real: ' + (params['uid'] || 'Auto-generated key')
              ]
            )
          end

          unless $CHILD_STATUS.success?
            raise Puppet::ParseError, 'Could not generate GPG key'
          end

          # rubocop:disable Style/IndentArray
          IO.popen([
            'gpg', '--homedir', dir, '--list-keys', '--with-fingerprint',
            '--with-colons', '--fixed-list-mode'
          ]) do |gpg|
            # rubocop:enable Style/IndentArray

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
                output['uid'] = Regexp.last_match(1).b.gsub(%r{((?:\\[0-9a-fA-F]{2})+)}) do |m|
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
      end
    end
  end
end
