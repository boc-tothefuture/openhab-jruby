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
	Replace <openhab_base_dir> with your base dir. This configuration with the openhab-scripting gem specified with [pessimistic versioning](https://thoughtbot.com/blog/rubys-pessimistic-operator) will install any version of openhab-scripting greater than 2.9 but less than 3.0. On system restart if any (non-breaking) new versions of the library are available they will automatically be installed. 
3. Install the latest JRuby Scripting Language Addon from [here](https://github.com/boc-tothefuture/openhab2-addons/releases) to the folder `<openhab_base_dir>/addons/`

## Upgrading
Depending on the versioning selected in the `jruby.cfg` file upgrading will either be automatic after a OpenHAB restart or manual.  For manual upgrades select the version of the gem exactly, for example:
	`org.openhab.automation.jrubyscripting:gems=openhab-scripting=2.9.3`

Will install and stay at version 2.9.3, to upgrade to version 2.9.4, change the configuration:
`org.openhab.automation.jrubyscripting:gems=openhab-scripting=2.9.4`

To automatically upgrade, it is recommended to use pessimistic versioning:
`org.openhab.automation.jrubyscripting:gems=openhab-scripting=~>2.9`
This will install at least version 2.9 and on every restart will automatically install any version that is less than 3.0. This ensures that fixes and new features are available without introducing any breaking changes.
