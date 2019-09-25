# put local configuration and setup here
require 'puppet_x/keypair/gpg'

class String
  def unindent
    gsub(%r{^#{scan(%r{^\s*}).min_by(&:length)}}, '')
  end
end
