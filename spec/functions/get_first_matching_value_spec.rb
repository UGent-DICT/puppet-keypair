require 'spec_helper'

describe 'get_first_matching_value' do
  it 'does exist' do
    expect(Puppet::Parser::Functions.function(:get_first_matching_value)).to eq('function_get_first_matching_value')
  end

  it 'does work without argument' do
    expect(scope.function_get_first_matching_value([])).to be_nil
  end

  it 'does work with nil keys and no criterium' do
    expect(scope.function_get_first_matching_value([nil])).to be_nil
  end

  it 'does work with nil keys and nil criterium' do
    expect(scope.function_get_first_matching_value([nil, nil])).to be_nil
  end

  it 'does work with "" key and no criterium' do
    expect(scope.function_get_first_matching_value([''])).to be_nil
  end

  it 'does work with "" key and "" criterium' do
    expect(scope.function_get_first_matching_value(['', ''])).to be_nil
  end

  it 'does return first element when no criteria is set' do
    expect(scope.function_get_first_matching_value([
                                                     { 'a' => { 'check' => 'mark' }, 'b' => {} }
                                                   ])).to be == { 'check' => 'mark' }
  end

  it 'does return what matches' do
    expect(scope.function_get_first_matching_value([
                                                     { 'a' => { 'check' => 'mark' }, 'b' => { 'check' => 'this' } },
                                                     { 'check' => 'this' }
                                                   ])).to be == { 'check' => 'this' }
  end
end
