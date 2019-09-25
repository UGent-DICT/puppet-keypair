require File.expand_path('../../puppet_x/keypair/gpg', __FILE__)

Facter.add(:gpg_keys) do
  setcode do
    dir = PuppetX::Keypair::GPG.keydir

    keys = {}
    begin
      if File.directory?(dir)
        Dir.foreach(dir) do |filename|
          next unless filename =~ %r{^([^.].*)\.(pub|sec)}
          basename = Regexp.last_match(1)

          keys[basename] = { 'basename' => basename } unless keys[basename]
          keys[basename]['keydir'] = dir
          keys[basename]['public_present'] = true if Regexp.last_match(2) == 'pub'
          keys[basename]['secret_present'] = true if Regexp.last_match(2) == 'sec'

          if Regexp.last_match(2) == 'pub'
            keys[basename]['public_key'] = File.read(dir + '/' + filename)
            IO.popen(['gpg', '--with-fingerprint', '--with-colons', '--fixed-list-mode', dir + '/' + filename], err: [:child, :out]) do |gpg|
              parsed_keys = PuppetX::Keypair::GPG.parse_gpg_io(gpg)
              unless parsed_keys.empty?
                keys[basename].merge!(parsed_keys.first)
              end
            end
          end
        end
      end
    rescue Errno::EACCES
      Facter.warn("gpg_keys fact could not access #{dir}: permission denied.")
      # can't access the file
    end

    keys
  end
end
