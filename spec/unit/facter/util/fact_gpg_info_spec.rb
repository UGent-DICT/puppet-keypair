require 'spec_helper'

describe Facter::Util::Fact do
  before(:each) do
    Facter.clear
  end

  let(:gpg1_version_output) do
    <<-VERSIONCODE.unindent
      gpg (GnuPG) 1.4.10
      Copyright (C) 2008 Free Software Foundation, Inc.
      License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
      This is free software: you are free to change and redistribute it.
      There is NO WARRANTY, to the extent permitted by law.

      Home: ~/.gnupg
      Supported algorithms:
      Pubkey: RSA, RSA-E, RSA-S, ELG-E, DSA
      Cipher: 3DES, CAST5, BLOWFISH, AES, AES192, AES256, TWOFISH, CAMELLIA128,
              CAMELLIA192, CAMELLIA256
      Hash: MD5, SHA1, RIPEMD160, SHA256, SHA384, SHA512, SHA224
      Compression: Uncompressed, ZIP, ZLIB, BZIP2
    VERSIONCODE
  end

  let(:gpg2_version_output) do
    <<-VERSIONCODE.unindent
      gpg (GnuPG) 2.2.14
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
    context 'gpg 2.x' do
      before(:each) do
        allow(Facter::Core::Execution).to receive(:which).and_call_original
        allow(Facter::Core::Execution).to receive(:which).with('gpg').and_return('/usr/local/bin/gpg')
        io = instance_double('IO')
        allow(io).to receive(:readlines) { gpg2_version_output.split("\n") }
        allow(IO).to receive(:popen).and_yield(io)
      end

      describe 'gpg_path' do
        it { expect(Facter.fact(:gpg_path).value).to eq('/usr/local/bin/gpg') }
      end
      describe 'gpg_version' do
        it { expect(Facter.fact(:gpg_version).value).to eq('2.2.14') }
      end
      describe 'gpg_info' do
        it { expect(Facter.fact(:gpg_info).value).to eq('version' => '2.2.14', 'path' => '/usr/local/bin/gpg', 'libgcrypt' => '1.8.3') }
      end
    end

    describe 'gpg 1.x' do
      before(:each) do
        allow(Facter::Core::Execution).to receive(:which).and_call_original
        allow(Facter::Core::Execution).to receive(:which).with('gpg').and_return('/usr/local/bin/gpg')

        io = instance_double('IO')
        allow(io).to receive(:readlines) { gpg1_version_output.split("\n") }
        allow(IO).to receive(:popen).and_yield(io)
      end

      describe 'gpg_path' do
        it { expect(Facter.fact(:gpg_path).value).to eq('/usr/local/bin/gpg') }
      end
      describe 'gpg_info' do
        it { expect(Facter.fact(:gpg_info).value).to eq('version' => '1.4.10', 'path' => '/usr/local/bin/gpg') }
      end
      describe 'gpg_version' do
        it { expect(Facter.fact(:gpg_version).value).to eq('1.4.10') }
      end
    end
  end
  context 'when gpg is not present' do
    before(:each) do
      allow(Facter::Core::Execution).to receive(:which).and_call_original
      allow(Facter::Core::Execution).to receive(:which).with('gpg').and_return(nil)
    end

    it 'nil version/path and empty gpg_info' do
      expect(Facter.fact(:gpg_info).value).to eq({})
      expect(Facter.fact(:gpg_path).value).to be_nil
      expect(Facter.fact(:gpg_version).value).to be_nil
    end
  end
end
