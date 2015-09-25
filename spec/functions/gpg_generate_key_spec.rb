require 'spec_helper'


describe 'gpg_generate_key' do

	it 'should exist' do
		expect( Puppet::Parser::Functions.function(:gpg_generate_key) ).to eq('function_gpg_generate_key')
	end

	context {
		let( :out ) {
			scope.function_gpg_generate_key(['uid' => "Bla é€", 'key_length' => 1024])
		}

		it 'should behave' do
			expect( out ).to include('fingerprint', 'secret_key', 'public_key')

			expect( out ).to include('uid' => "Bla é€")
			expect( out ).to include('key_length' => 1024)
		end
	}

	context {
		let( 'out' ) {
			scope.function_gpg_generate_key(['key_length' => 16])
		}

		it 'should behave' do
			expect( out ).to include('fingerprint', 'secret_key', 'public_key')

			expect( out ).to include('uid')
			expect( out['uid'] ).to match(/./)

			expect( out ).to include('key_length')
			expect( out['key_length'] ).to be >= 1024
		end
	}

end
