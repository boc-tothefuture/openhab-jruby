---
layout: default
title: Installation
nav_order: 3
has_children: false
---

## Prerequisites
1. OpenHAB 3
2. The JRuby Scripting Language Addon
3. This scripting library



## Installation
1. Install the latest Jruby Scripting Language Addon from [here](https://github.com/boc-tothefuture/openhab-jruby/releases/) to the folder `<openhab_base_dir>/addons/`
2. Create directory for JRuby Libraries `<openhab_base_dir>/conf/automation/lib/ruby/lib`
3. Create directory for Ruby Gems `<openhab_base_dir>/conf/automation/lib/ruby/gem_home`
4. Download latest JRuby Libraries from [here](https://github.com/boc-tothefuture/openhab-jruby/releases/)
5. Install libraries in `<openhab_base_dir>/conf/automation/lib/ruby/lib`
6. Update OpenHAB start.sh with the following environment variables so that the library can be loaded and gems can be installed
```
export RUBYLIB=<openhab_base_dir>/conf/automation/lib/ruby/lib
export GEM_HOME=<openhab_base_dir>/conf/automation/lib/ruby/gem_home
```
7. Restart OpenHAB
