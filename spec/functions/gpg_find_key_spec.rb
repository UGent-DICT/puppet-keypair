require 'spec_helper'


describe 'gpg_find_key' do

	it 'should exist' do
		expect( Puppet::Parser::Functions.function(:gpg_find_key) ).to eq('function_gpg_find_key')
	end

	it 'should work without argument' do
		expect( scope.function_gpg_find_key([]) ).to be_nil
	end

	it 'should work with nil argument' do
		expect( scope.function_gpg_find_key([nil]) ).to be_nil
		expect( scope.function_gpg_find_key([nil, nil]) ).to be_nil
	end

	it 'should work with "" argument' do
		expect( scope.function_gpg_find_key([""]) ).to be_nil
		expect( scope.function_gpg_find_key(["", ""]) ).to be_nil
	end

	it 'should return everything when no criteria is set' do
		expect( scope.function_gpg_find_key([
			{'a' => {'check' => 'mark'}, 'b' => {}}
		]) ).to be == {'check' => 'mark'}
	end

	it 'should return what matches' do
		expect( scope.function_gpg_find_key([
			{'a' => {'check' => 'mark'}, 'b' => {'check' => 'this'}},
			{'check' => 'this'}
		]) ).to be == {'check' => 'this'}
	end

end
