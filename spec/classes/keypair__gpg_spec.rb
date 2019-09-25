require 'spec_helper'

describe 'keypair::gpg' do
  let(:pre_condition) do
    <<-puppet
    function keypair::gpg_keydir() {
      '/etc/puppet_keypairs'
    }
    puppet
  end

  context 'manage => true' do
    let(:params) { { manage_dir: true } }

    it { is_expected.to compile }
    it do
      is_expected.to contain_file('/etc/puppet_keypairs')
    end
  end

  context 'manage => false' do
    let(:params) { { manage_dir: false } }

    it { is_expected.to compile }
    it do
      is_expected.not_to contain_file('/etc/puppet_keypairs')
    end
  end
end
