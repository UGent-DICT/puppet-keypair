require 'spec_helper'

describe 'x509_generate_key' do
  context 'handle parameters' do
    it do
      is_expected.to run.with_params('CN' => 'www.example.org', 'key_length' => 512)
    end
    it do
      is_expected.to run.with_params(512, 'www.example.org')
    end
    it do
      is_expected.to run.with_params('www.example.org')
    end
    it do
      is_expected.to run.with_params(512)
    end
    it do
      is_expected.to run.with_params
    end
  end

  context do
    let(:out) do
      subject.execute('CN' => 'www.example.org', 'key_length' => 512)
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
