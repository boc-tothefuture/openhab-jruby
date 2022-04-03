---
layout: default
title: Logging
nav_order: 1
has_children: false
parent: Misc
grand_parent: Usage
---

# Logging

Logging is available everywhere through the `logger` object.

The logging prefix is `org.openhab.automation.jruby`. Logging within file-based rules
will have the name of the file appended to the logger name. The following entries are in a file named 'log_test.rb'

```ruby
logger.trace('Test logging at trace') # 2020-12-03 18:05:20.903 [TRACE] [org.openhab.automation.jruby.log_test] - Test logging at trace
logger.debug('Test logging at debug') # 2020-12-03 18:05:32.020 [DEBUG] [org.openhab.automation.jruby.log_test] - Test logging at debug
logger.warn('Test logging at warn')   # 2020-12-03 18:05:41.817 [WARN ] [org.openhab.automation.jruby.log_test] - Test logging at warn
logger.info('Test logging at info')   # 2020-12-03 18:05:41.817 [INFO ] [org.openhab.automation.jruby.log_test] - Test logging at info
logger.error('Test logging at error') # 2020-12-03 18:06:02.021 [ERROR] [org.openhab.automation.jruby.log_test] - Test logging at error
```

Logging inside of a rule will have the name of the rule appened to the logger name. The following entries are in a file named 'log_test.rb'

```ruby
rule 'foo' do
  run { logger.trace('Test logging at trace') } # 2020-12-03 18:05:20.903 [TRACE] [org.openhab.automation.jruby.log_test.foo] - Test logging at trace
  on_start
end
```

## Logger Methods

The `logger` object has the following methods:

* `info`, `warn`, `error`, `debug`, and `trace` log a message at the corresponding level. They can accept a block
  that returns a string. The block is executed if the log level is enabled.
* `info_enabled?`, `warn_enabled?`, `error_enabled?`, `debug_enabled?`, and `trace_enabled?` return true if the log level is enabled.


### Example

```ruby
logger.trace do
  total = Item1 + Item2
  average = total / 2
 "Total: #{total}, Average: #{average}" 
end
```
