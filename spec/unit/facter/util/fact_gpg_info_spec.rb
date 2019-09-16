require 'spec_helper'

class String
  def unindent
    gsub(%r{^#{scan(%r{^\s*}).min_by(&:length)}}, '')
  end
end

describe Facter::Util::Fact do
  before do
    Facter.clear
  end

  let(:gpg_version_output) do
    <<-VERSIONCODE.unindent
      gpg (GnuPG) 2.2.17
      libgcrypt 1.8.3
      Copyright (C) 2019 Free Software Foundation, Inc.
      License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>
      This is free software: you are free to change and redistribute it.
      There is NO WARRANTY, to the extent permitted by law.

      Home: /root/.gnupg
      Supported algorithms:
      Pubkey: RSA, ELG, DSA, ECDH, ECDSA, EDDSA
      Cipher: IDEA, 3DES, CAST5, BLOWFISH, AES, AES192, AES256, TWOFISH,
              CAMELLIA128, CAMELLIA192, CAMELLIA256
      Hash: SHA1, RIPEMD160, SHA256, SHA384, SHA512, SHA224
      Compression: Uncompressed, ZIP, ZLIB, BZIP2
    VERSIONCODE
  end

  context 'when gpg is present in path' do
    it do
      Facter::Core::Execution.expects(:which).at_least(1)
      Facter::Core::Execution.expects(:which).at_least(1).with('gpg').returns('/usr/local/bin/gpg')
      Facter::Core::Execution.expects(:execute).at_least(1)
      Facter::Core::Execution.expects(:execute).with('/usr/local/bin/gpg --version').returns(gpg_version_output)
      Facter.fact(:gpg_path).value.should eq('/usr/local/bin/gpg')
      Facter.fact(:gpg_info).value.should eq('version' => '2.2.17', 'path' => '/usr/local/bin/gpg', 'libgcrypt' => '1.8.3')
      Facter.fact(:gpg_version).value.should eq('2.2.17')
    end
  end
  context 'when gpg is not present' do
    it do
      Facter::Core::Execution.expects(:which).at_least(1).with('gpg').returns(nil)
      Facter.fact(:gpg_info).value.should eq({})
      Facter.fact(:gpg_path).value.should be_nil
      Facter.fact(:gpg_version).value.should be_nil
    end
  end
end
