require 'facter'

Facter.add(:gpg_path) do
  setcode do
    Facter::Core::Execution.which('gpg')
  end
end

Facter.add(:gpg_info) do
  setcode do
    gpg_info = {}
    gpg_path = Facter.value(:gpg_path)
    if gpg_path
      gpg_info['path'] = gpg_path
      IO.popen([gpg_path, '--version'], err: [:child, :out]) do |output|
        output.readlines.each do |line|
          if line =~ %r{^gpg \(GnuPG\) (\d.*)$}
            gpg_info['version'] = Regexp.last_match(1)
            next
          elsif line =~ %r{^libgcrypt (\d.*)$}
            gpg_info['libgcrypt'] = Regexp.last_match(1)
            next
          end
        end
      end
    end
    gpg_info
  end
end

Facter.add(:gpg_version) do
  setcode do
    gpg_info = Facter.value(:gpg_info)
    gpg_info['version']
  end
end
