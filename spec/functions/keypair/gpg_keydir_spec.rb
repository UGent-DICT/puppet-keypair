require 'spec_helper'

describe 'keypair::gpg_keydir' do
  it 'exists' do
    is_expected.not_to be_nil
  end

  describe 'returns the gpg dir from PuppetX::Keypair::GPG' do
    before(:each) do
      allow(PuppetX::Keypair::GPG).to receive(:keydir).and_return('/etc/puppet_keypairs')
    end

    it do
      is_expected.to run.and_return('/etc/puppet_keypairs')
    end
  end
end
