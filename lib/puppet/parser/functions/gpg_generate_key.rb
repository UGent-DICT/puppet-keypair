module Puppet::Parser::Functions

	newfunction(:gpg_generate_key, :type => :rvalue) do |args|
		params = args.shift || {}

		output = {:params => params}

		Dir.mktmpdir {|dir|
			IO.popen(['gpg', '--homedir', dir, '--batch', '--gen-key'], 'r+') {|gpg|
				gpg.puts([
					'Key-Type: RSA',
					'Key-Length: ' + (params['key_length'] || 2048).to_s,
					'Key-Usage: sign',
					'Name-Real: ' + (params['uid'] || 'Auto-generated key'),
				])
			}
			raise Puppet::ParseError, 'Could not generate GPG key' unless $?.success?

			IO.popen(['gpg', '--homedir', dir, '--list-keys', '--with-fingerprint', '--with-colons', '--fixed-list-mode']) {|gpg|
				gpg.readlines.each {|line|
					# We just generated a single key in a new directory
					# so we don't need to track which uid belongs to which public key
					if line =~ /^pub:[^:]*:(\d+):(\d+):([0-9a-fA-F]+)/
						output['key_length'] = $1.to_i
						output['algo'] = $2.to_i
						output['keyid'] = $3
					elsif line =~ /^fpr:::::::::([0-9a-fA-F]+)/
						output['fingerprint'] = $1
					elsif line =~ /^uid:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:([^:]*):/
						output['uid'] = $1.b.gsub(/((?:\\[0-9a-fA-F]{2})+)/) do |m|
							[m.delete('\\')].pack('H*')
						end.force_encoding('UTF-8')
					end
				}
			}

			IO.popen(['gpg', '--homedir', dir, '--armour', '--export', output['keyid']]) {|gpg|
				output['public_key'] = gpg.read
			}

			IO.popen(['gpg', '--homedir', dir, '--armour', '--export-secret-key', output['keyid']]) {|gpg|
				output['secret_key'] = gpg.read
			}
		}

		output
	end

end
