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

      # Parse a IO stream (IO.popen) and extract (gpg) key information.
      # You should use the folling gpg options to get a parseable result:
      # `gpg --list-keys --with-fingerprint --with-colon --fixed-list-mode`
      def self.parse_gpg_io(io)
        keys = []
        current = {}
        io.readlines.each do |line|
          if line =~ %r{^pub:[^:]*:(\d+):(\d+):([0-9a-fA-F]+):[^:]*:[^:]*:[^:]*:[^:]*:([^:]*):}
            # check if we are starting a new key.
            if current['keyid'] && current['keyid'] != Regexp.last_match(3)
              keys << current
              current = {}
            end
            current['key_length'] = Regexp.last_match(1).to_i
            current['algo'] = Regexp.last_match(2).to_i
            current['keyid'] = Regexp.last_match(3)
            unless Regexp.last_match(4).empty?
              current['uid'] = Regexp.last_match(4).clone.gsub(%r{((?:\\[0-9a-fA-F]{2})+)}) { |m|
                [m.delete('\\')].pack('H*')
              }.force_encoding('UTF-8')
            end
          elsif line =~ %r{^fpr:::::::::([0-9a-fA-F]+)}
            current['fingerprint'] = Regexp.last_match(1)
          elsif line =~ %r{^uid:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:([^:]*):}
            current['uid'] = Regexp.last_match(1).clone.gsub(%r{((?:\\[0-9a-fA-F]{2})+)}) { |m|
              [m.delete('\\')].pack('H*')
            }.force_encoding('UTF-8')
          end
        end
        if current['keyid']
          keys << current
        end
        keys
      end
    end
  end
end
