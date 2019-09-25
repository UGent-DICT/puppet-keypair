Facter.add(:x509_keys) do
  setcode do
    dir = '/etc/ssl/private'

    keys = {}
    begin
      if File.directory?(dir)
        Dir.foreach(dir) do |filename|
          next unless filename =~ %r{^([^.].*)\.(key|crt)}
          basename = Regexp.last_match(1)

          keys[basename] = { 'basename' => basename } unless keys[basename]

          keys[basename]['cert_present']   = true if Regexp.last_match(2) == 'crt'
          keys[basename]['secret_present'] = true if Regexp.last_match(2) == 'key'

          if Regexp.last_match(2) == 'crt'
            keys[basename]['cert'] = File.read(dir + '/' + filename)
          end
        end
      end
    rescue Errno::EACCES => ex
      Facter.warn("x509_keys fact could not access #{dir}: permission denied.")
      # can't access the file
    end
    keys
  end
end
