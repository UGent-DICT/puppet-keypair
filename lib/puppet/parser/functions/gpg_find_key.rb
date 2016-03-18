# rubocop:disable Style/ClassAndModuleChildren, Documentation

module Puppet::Parser::Functions
  newfunction(:gpg_find_key, type: :rvalue, doc: <<-EODOC

    @TODO: Write documentation / example use for the function.

  EODOC
             ) do |args|
    keys = args.shift || {}
    criteria = args.shift || {}

    keys = {} if keys == ''

    criteria = {} if criteria == ''

    matching_keys = keys.keep_if do |_key, value|
      keep = true
      criteria.keys.each do |c|
        keep &&= criteria[c] == value[c]
      end
      keep
    end

    if matching_keys.empty?
      nil
    else
      matching_keys[matching_keys.keys[0]]
    end
  end
end
