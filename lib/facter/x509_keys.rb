Facter.add(:x509_keys) do
  setcode do
    dir = '/etc/ssl/private'

    keys = {}

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

    if keys.empty?
      # Special case for first run:
      # On first run, we may be running with `stringify_facts=true`
      # This special case allows us to get past that first run
      ''
    else
      keys
    end
  end
end
