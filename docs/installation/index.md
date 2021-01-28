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
1. Create directory for Ruby Gems `<openhab_base_dir>/conf/automation/lib/ruby/gem_home`
2. Configure JRuby OpenHAB services
	1. Create a file called `jruby.cfg` in `<openhab_base_dir>/conf/services/` with the following content:
  ```
	org.openhab.automation.jrubyscripting:gem_home=<openhab_base_dir>/conf/automation/lib/ruby/gem_home
		org.openhab.automation.jrubyscripting:gems=openhab-scripting=~>2.9

```
		
		Replace <openhab_base_dir> with your base dir. This configuration with the openhab-scripting gem specified with [pessimistic versioning](https://thoughtbot.com/blog/rubys-pessimistic-operator) will install any verison of openhab-scripting greater than 2.9 but less than 3.0. On system restrart if any (non-breaking) new versions of the library are available they will automatically be installed. 
3. Install the latest JRuby Scripting Language Addon from [here](https://github.com/boc-tothefuture/openhab2-addons/releases) to the folder `<openhab_base_dir>/addons/`