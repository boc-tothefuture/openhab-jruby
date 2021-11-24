---
layout: default
title: Logging
nav_order: 1
has_children: false
parent: Misc
grand_parent: Usage
---

# Logging

Logging is available everywhere through the logger object. The name of the rule file is automatically appended to the logger name.

```ruby
logger.trace('Test logging at trace') # 2020-12-03 18:05:20.903 [TRACE] [jsr223.jruby.log_test               ] - Test logging at trace
logger.debug('Test logging at debug') # 2020-12-03 18:05:32.020 [DEBUG] [jsr223.jruby.log_test               ] - Test logging at debug
logger.warn('Test logging at warn')   # 2020-12-03 18:05:41.817 [WARN ] [jsr223.jruby.log_test               ] - Test logging at warn
logger.info('Test logging at info')   # 2020-12-03 18:05:42.215 [WARN ] [jsr223.jruby.log_test               ] - Test logging at info
logger.error('Test logging at error') # 2020-12-03 18:06:02.021 [ERROR] [jsr223.jruby.log_test               ] - Test logging at error
```

When called from within a rule, the name of the rule will be used instead of the file name.

```ruby
rule 'my rule' do
  on_start
  run { logger.info('Hello World!') } # 08:48:45.192 [INFO ] [jsr223.jruby.my_rule                 ] - Hello World!
end
```

A custom suffix can be supplied as an argument to logger.

```ruby
logger('my_custom_logging').info('Hello World!') # 08:52:14.185 [INFO ] [jsr223.jruby.my_custom_logging       ] - Hello World!
```

To use the custom suffix multiple times:

```ruby
log = logger('my_custom_logging')
log.info('Hi')
log.info('Hi Again!')
```
