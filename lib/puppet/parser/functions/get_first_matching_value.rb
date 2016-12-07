module Puppet
  module Parser
    module Functions
      newfunction(:get_first_matching_value, type: :rvalue, doc: <<-EODOC
    get_first_matching_value(key_hash, criteria_hash)

    Filters key_hash, returning the first (usually only) element to match
    criteria_hash:

    get_first_matching_value( { one   => {a => 1, b => 2},
                                two   => {a => 1, b => 3},
                                three => {a => 2},
                              },
                              { a => 1 }
                            )
    returns:
    {a => 1, b => 2}

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
  end
end
