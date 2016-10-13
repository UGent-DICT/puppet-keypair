require 'spec_helper'

describe 'gpg_generate_key' do
  it 'does exist' do
    expect(Puppet::Parser::Functions.function(:gpg_generate_key)).to eq('function_gpg_generate_key')
  end

  context do
    let(:out) do
      scope.function_gpg_generate_key(['uid' => 'Bla é€', 'key_length' => 1024])
    end

    it 'does return attributes' do
      expect(out).to include('fingerprint', 'secret_key', 'public_key', 'uid', 'key_length')
    end

    it 'does return the correct uid' do
      expect(out).to include('uid' => 'Bla é€')
    end

    it 'does return the correct key_length' do
      expect(out).to include('key_length' => 1024)
    end
  end

  context do
    let('out') do
      scope.function_gpg_generate_key(['key_length' => 16])
    end

    it 'does return attributes' do
      expect(out).to include('fingerprint', 'secret_key', 'public_key', 'uid', 'key_length')
    end

    it 'does have an UID' do
      expect(out['uid']).to match(%r{.})
    end

    it 'does have an minimum key_length' do
      expect(out['key_length']).to be >= 1024
    end
  end
end
