require 'spec_helper'

describe 'x509_generate_key' do
  it 'does exist' do
    expect(Puppet::Parser::Functions.function(:x509_generate_key)).to eq('function_x509_generate_key')
  end

  context do
    let(:out) do
      scope.function_x509_generate_key(['CN' => 'www.example.org', 'key_length' => 512])
    end

    it 'does return attributes' do
      expect(out).to include('secret_key', 'cert', 'CN', 'key_length')
    end

    it 'does return the correct CN' do
      expect(out).to include('CN' => 'www.example.org')
    end

    it 'does return the correct key_length' do
      expect(out).to include('key_length' => 512)
    end
  end
end
