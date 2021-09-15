---
layout: default
title: Shared Code
nav_order: 2
has_children: false
parent: Misc
grand_parent: Usage
---

# Shared Code

If you would like to easily share code among multiple rules files, you can
place it in `<OPENHAB_CONF>/automation/lib/ruby/personal`. Assuming `$RUBYLIB`
is set up correctly in `jruby.conf` (see [Installation](../../../installation)),
you can then simply `require` the file from your rules files. Because the
library files _aren't_ in the `jsr223` directory, they won't be automatically
loaded individually by OpenHAB, only when you `require` them.

`automation/jsr223/ruby/personal/myrule.rb`
```ruby
require "openhab"
require "my_lib"

logger.info(my_lib_version)
```

`automation/lib/ruby/personal/my_lib.rb`
```ruby
def my_lib_version
  "1.0"
end
```
