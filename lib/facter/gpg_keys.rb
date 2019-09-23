# rubocop:disable Metrics/BlockLength
Facter.add(:gpg_keys) do
  setcode do
    dir = '/etc/gpg_keys'

    keys = {}
    begin
      if File.directory?(dir)
        Dir.foreach(dir) do |filename|
          next unless filename =~ %r{^([^.].*)\.(pub|sec)}
          basename = Regexp.last_match(1)

          keys[basename] = { 'basename' => basename } unless keys[basename]

          keys[basename]['public_present'] = true if Regexp.last_match(2) == 'pub'
          keys[basename]['secret_present'] = true if Regexp.last_match(2) == 'sec'

          if Regexp.last_match(2) == 'pub'
            keys[basename]['public_key'] = File.read(dir + '/' + filename)
            IO.popen(['gpg', '--with-fingerprint', '--with-colons', dir + '/' + filename]) do |gpg|
              gpg.readlines.each do |line|
                # We're reading in a single key
                # so we don't need to track which uid belongs to which public key
                if line =~ %r{^pub:[^:]*:(\d+):(\d+):([0-9a-fA-F]+):[^:]*:[^:]*:[^:]*:[^:]*:([^:]*):}
                  keys[basename]['key_length'] = Regexp.last_match(1).to_i
                  keys[basename]['algo'] = Regexp.last_match(2).to_i
                  keys[basename]['keyid'] = Regexp.last_match(3)
                  keys[basename]['uid'] = Regexp.last_match(4).b.gsub(%r{((?:\\[0-9a-fA-F]{2})+)}) do |m|
                    [m.delete('\\')].pack('H*')
                  end.force_encoding('UTF-8')
                elsif line =~ %r{^fpr:::::::::([0-9a-fA-F]+)}
                  keys[basename]['fingerprint'] = Regexp.last_match(1)
                end
              end
            end
          end
        end
      end
    rescue Errno::EACCES => ex
      Facter.warn("gpg_keys fact could not access #{dir}: permission denied.")
      # can't access the file
    end

    keys
  end
end
