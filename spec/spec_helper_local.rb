# put local configuration and setup here

class String
  def unindent
    gsub(%r{^#{scan(%r{^\s*}).min_by(&:length)}}, '')
  end
end
