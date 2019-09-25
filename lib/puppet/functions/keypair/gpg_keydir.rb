require File.expand_path('../../../../puppet_x/keypair/gpg', __FILE__)

Puppet::Functions.create_function(:'keypair::gpg_keydir') do
  # Returns the gpg keydir used in this module.
  dispatch :gpg_keydir do
  end

  def gpg_keydir
    PuppetX::Keypair::GPG.keydir
  end
end
