# rubocop:disable Style/ClassAndModuleChildren :
# rubocop wants us to use `class PuppetX::Keypair::GPG` which we can't
# since the parent modules `PuppetX` and `PuppetX::Keypair` do not exist yet.
module PuppetX
  # Extra keypair libs
  module Keypair
    # GPG helpers.
    module GPG
      def self.keydir
        '/etc/gpg_keys'
      end
    end
  end
end
