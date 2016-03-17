module Puppet::Parser::Functions

  newfunction(:gpg_find_key, :type => :rvalue) do |args|
    keys = args.shift || {}
    criteria = args.shift || {}

    if keys == ""
      keys = {}
    end

    if criteria == ""
      criteria = {}
    end

    matching_keys = keys.keep_if { |key, value|
      keep = true
      criteria.keys.each { |c|
        keep &&= criteria[c] == value[c]
      }
      keep
    }

    if matching_keys.length == 0
      nil
    else
      matching_keys[ matching_keys.keys[0] ]
    end
  end

end
