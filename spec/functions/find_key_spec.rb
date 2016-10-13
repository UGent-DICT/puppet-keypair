require 'spec_helper'

describe 'find_key' do
  it 'does exist' do
    expect(Puppet::Parser::Functions.function(:find_key)).to eq('function_find_key')
  end

  it 'does work without argument' do
    expect(scope.function_find_key([])).to be_nil
  end

  it 'does work with nil keys and no criterium' do
    expect(scope.function_find_key([nil])).to be_nil
  end

  it 'does work with nil keys and nil criterium' do
    expect(scope.function_find_key([nil, nil])).to be_nil
  end

  it 'does work with "" key and no criterium' do
    expect(scope.function_find_key([''])).to be_nil
  end

  it 'does work with "" key and "" criterium' do
    expect(scope.function_find_key(['', ''])).to be_nil
  end

  it 'does return first element when no criteria is set' do
    expect(scope.function_find_key([
                                     { 'a' => { 'check' => 'mark' }, 'b' => {} }
                                   ])).to be == { 'check' => 'mark' }
  end

  it 'does return what matches' do
    expect(scope.function_find_key([
                                     { 'a' => { 'check' => 'mark' }, 'b' => { 'check' => 'this' } },
                                     { 'check' => 'this' }
                                   ])).to be == { 'check' => 'this' }
  end
end
