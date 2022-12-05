# @title Shared Code

# Shared Code

If you would like to easily share code among multiple rules files, you can
place it in `<OPENHAB_CONF>/automation/ruby/lib`. Assuming `$RUBYLIB`
is set up correctly in `jruby.conf` (see [Installation](../../installation.md)),
you can then simply `require` the file from your rules files. Files located in
`$RUBYLIB` won't be automatically loaded individually by openHAB, only when you `require` them.

`automation/ruby/myrule.rb`
```ruby
require "my_lib"

logger.info(my_lib_version)
```

`automation/ruby/lib/my_lib.rb`
```ruby
def my_lib_version
  "1.0"
end
```
