require 'spec_helper'

require 'puppet_x/keypair/gpg'

describe PuppetX::Keypair::GPG do
  describe 'no keys' do
    let(:output) { '' }

    it do
      io = instance_double('IO')
      allow(io).to receive(:readlines) { output.split("\n") }

      expect(described_class.parse_gpg_io(io)).to eq([])
    end
  end

  describe 'parse a single key (gpg1)' do
    let(:output) do
      <<-OUTPUT.unindent
        pub:-:2048:1:51A967C4EA88C58F:1569404883:::-:Aptly repo server signing key:
        fpr:::::::::644C1EF3F0B831DDCE9EBD3D51A967C4EA88C58F:
      OUTPUT
    end
    let(:parsed) do
        [{
          'algo' => 1,
          'fingerprint' => '644C1EF3F0B831DDCE9EBD3D51A967C4EA88C58F',
          'key_length'  => 2048,
          'keyid'       => '51A967C4EA88C58F',
          'uid'         => 'Aptly repo server signing key'
        }]
    end

    it 'returns a single key' do
      io = instance_double('IO')
      allow(io).to receive(:readlines) { output.split("\n") }

      expect(described_class.parse_gpg_io(io)).to eq(parsed)
    end
  end

  describe 'parse a single key (gpg2)' do
    let(:output) do
      <<-OUTPUT.unindent
        gpg: WARNING: unsafe permissions on homedir '/tmp/spec/fixtures/certificates'
        tru::1:1569258565:0:3:1:5
        pub:u:1024:1:CBD11408E914BAD1:1569258537:::u:::scSC::::::::0:
        fpr:::::::::2CF27DBD938AF18934A3E888CBD11408E914BAD1:
        uid:u::::1569258537::46E113E588AC5287649ACD886BAFDB7310B5E2EA::My key name YAY\\x3a testing::::::::::0:
      OUTPUT
    end

    let(:parsed) do
      [{
        'algo' => 1,
        'fingerprint' => '2CF27DBD938AF18934A3E888CBD11408E914BAD1',
        'key_length' => 1024,
        'keyid' => 'CBD11408E914BAD1',
        'uid' => 'My key name YAY\\x3a testing',
      }]
    end

    it 'returns a single key' do
      io = instance_double('IO')
      allow(io).to receive(:readlines) { output.split("\n") }

      expect(described_class.parse_gpg_io(io)).to eq(parsed)
    end
  end

  describe 'parse multiple key (gpg2)' do
    let(:output) do
      <<-OUTPUT.unindent
        gpg: WARNING: unsafe permissions on homedir '/tmp/spec/fixtures/certificates'
        gpg: checking the trustdb
        gpg: marginals needed: 3  completes needed: 1  trust model: pgp
        gpg: depth: 0  valid:   2  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 2u
        tru:o:1:1569258565:1:3:1:5
        pub:u:1024:1:CBD11408E914BAD1:1569258537:::u:::scSC::::::::0:
        fpr:::::::::2CF27DBD938AF18934A3E888CBD11408E914BAD1:
        uid:u::::1569258537::46E113E588AC5287649ACD886BAFDB7310B5E2EA::My key name YAY\\x3a testing::::::::::0:
        pub:u:1024:1:59DD5930D536F772:1569259166:::u:::scSC::::::::0:
        fpr:::::::::0B70FB6322D4C0BFF068AD5E59DD5930D536F772:
        uid:u::::1569259166::DF02BBF23C0FC1205AEE9040933A64B3B2C12B28::Deal with more than one too::::::::::0:
      OUTPUT
    end

    let(:parsed) do
      [{
        'algo' => 1,
        'fingerprint' => '2CF27DBD938AF18934A3E888CBD11408E914BAD1',
        'key_length' => 1024,
        'keyid' => 'CBD11408E914BAD1',
        'uid' => 'My key name YAY\\x3a testing',
      },
       {
         'algo' => 1,
         'fingerprint' => '0B70FB6322D4C0BFF068AD5E59DD5930D536F772',
         'key_length' => 1024,
         'keyid' => '59DD5930D536F772',
         'uid' => 'Deal with more than one too',
       }]
    end

    it 'returns multiple keys' do
      io = instance_double('IO')
      allow(io).to receive(:readlines) { output.split("\n") }
      expect(described_class.parse_gpg_io(io)).to eq(parsed)
    end

    # it 'should work for real' do
    #   IO.popen(['gpg', '--homedir', 'spec/fixtures/certificates', '--list-keys',
    #          '--with-fingerprint', '--with-colons', '--fixed-list-mode']) do |io|
    #     expect(PuppetX::Keypair::GPG.parse_gpg_io(io)).to eq(parsed)
    #   end
    # end
  end
end
