Facter.add(:gpg_keys) do
	setcode do
		dir = '/etc/gpg_keys'

		keys = {}

		if File.directory?(dir)
			Dir.foreach(dir) do |filename|
				next unless filename =~ /^([^.].*)\.(pub|sec)/
				basename = $1

				keys[basename] = {'basename' => basename} unless keys[basename]

				keys[basename]['public_present'] = true if $2 == 'pub'
				keys[basename]['secret_present'] = true if $2 == 'sec'

				if $2 == 'pub'
					keys[basename]['public_key'] = File.read(dir + '/' + filename)
					IO.popen(['gpg', '--with-fingerprint', '--with-colons', dir + '/' + filename]) {|gpg|
						gpg.readlines.each {|line|
							# We're reading in a single key
							# so we don't need to track which uid belongs to which public key
							if line =~ /^pub:[^:]*:(\d+):(\d+):([0-9a-fA-F]+):[^:]*:[^:]*:[^:]*:[^:]*:([^:]*):/
								keys[basename]['key_length'] = $1.to_i
								keys[basename]['algo'] = $2.to_i
								keys[basename]['keyid'] = $3
								keys[basename]['uid'] = $4.b.gsub(/((?:\\[0-9a-fA-F]{2})+)/) do |m|
									[m.delete('\\')].pack('H*')
								end.force_encoding('UTF-8')
							elsif line =~ /^fpr:::::::::([0-9a-fA-F]+)/
								keys[basename]['fingerprint'] = $1
							end
						}
					}
				end

			end
		end

		keys
	end
end
