---
layout: default
title: Gem Cleanup
nav_order: 2
has_children: false
parent: Examples
---

## Gem Cleanup

The Openhab JRuby add-on will automatically download and install the latest version of the library according to the [settings in jruby.cfg](../../installation/#installation). Over time, the older versions of the library will accumulate in the gem_home directory. The following code saved as `gem_cleanup.rb` or another name of your choice can be placed in the `jsr223/ruby/personal/` directory to perform uninstallation of the older gem versions.

```ruby
require 'rubygems/commands/uninstall_command'

cmd = Gem::Commands::UninstallCommand.new

# uninstall all the older versions of the openhab-scripting gems
Gem::Specification.find_all
                  .select { |gem| gem.name == 'openhab-scripting' }
                  .sort_by(&:version)
                  .tap(&:pop) # don't include the latest version
                  .each do |gem|
  cmd.handle_options ['-x', '-I', gem.name, '--version', gem.version.to_s]
  cmd.execute
end
```
