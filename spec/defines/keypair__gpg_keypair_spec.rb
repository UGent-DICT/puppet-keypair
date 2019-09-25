require 'spec_helper'

describe 'keypair::gpg_keypair' do
  let(:title) { 'mykey' }
  let(:params) { { basename: 'mykey', uid: 'My UID' } }
  let(:keydir) { '/etc/puppet_keypair' }

  context 'new key' do
    let(:pre_condition) do
      <<-puppet
      function keypair::gpg_keydir() {
        "#{keydir}"
      }
      function gpg_generate_key(Hash $opts) {
        $opts + {
          'secret_key' => 'very secret',
          'public_key' => 'public',
        }
      }
    puppet
    end

    let(:facts) do
      { gpg_keys: {} }
    end

    it { is_expected.to compile }
    it { is_expected.to contain_class('keypair::gpg') }
    it { is_expected.to contain_file("#{keydir}/mykey.sec").with_content('very secret') }
    it { is_expected.to contain_file("#{keydir}/mykey.pub").with_content('public') }
  end

  context 'key already exists' do
    let(:pre_condition) do
      <<-puppet
      function keypair::gpg_keydir() {
        "#{keydir}"
      }
      function gpg_generate_key(Hash $opts) {
        fail('if the key exists, we should never be here')
      }
      puppet
    end
    let(:facts) do
      {
        gpg_keys: {
          'mykey' => {
            'basename'       => 'mykey',
            'secret_present' => true,
            'public_key'     => 'public exists',
          },
        },
      }
    end

    it { is_expected.to compile }
    it { is_expected.to contain_class('keypair::gpg') }
    it { is_expected.to contain_file("#{keydir}/mykey.sec").with_ensure('file').with_content(nil) }
    it { is_expected.to contain_file("#{keydir}/mykey.pub").with_ensure('file').with_content('public exists') }
  end
end
