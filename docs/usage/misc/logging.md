---
layout: default
title: Logging
nav_order: 1
has_children: false
parent: Misc
grand_parent: Usage
---

# Logging

Logging is available everywhere through the logger object.  The name of the rule file is automatically appended to the logger name. Pending [merge](https://github.com/openhab/openhab-core/pull/1885) into the core.

```ruby
logger.trace('Test logging at trace') # 2020-12-03 18:05:20.903 [TRACE] [jsr223.jruby.log_test               ] - Test logging at trace
logger.debug('Test logging at debug') # 2020-12-03 18:05:32.020 [DEBUG] [jsr223.jruby.log_test               ] - Test logging at debug
logger.warn('Test logging at warn') # 2020-12-03 18:05:41.817 [WARN ] [jsr223.jruby.log_test               ] - Test logging at warn
logger.info('Test logging at info') # Test logging at info
logger.error('Test logging at error') # 2020-12-03 18:06:02.021 [ERROR] [jsr223.jruby.log_test               ] - Test logging at error
```

