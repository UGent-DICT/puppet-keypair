require 'spec_helper'

describe 'gpg_generate_key' do
  context 'handle parameters' do
    it do
      is_expected.to run.with_params(1024, 'UID')
    end
    it do
      is_expected.to run.with_params('UID')
    end
    it do
      is_expected.to run.with_params(512)
    end
    it do
      is_expected.to run.with_params
    end
    it do
      is_expected.to run.with_params('key_length' => 1024, 'uid' => 'UID')
    end
  end

  context do
    let(:out) do
      subject.execute(1024, 'Bla é€')
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
    let(:out) do
      subject.execute(16)
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
