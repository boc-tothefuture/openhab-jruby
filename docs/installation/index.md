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

1. Create directory for Ruby Gems `<OPENHAB_CONF>/automation/lib/ruby/gem_home`
2. Configure JRuby OpenHAB services
   
   Create a file called `jruby.cfg` in `<OPENHAB_CONF>/services/` with the following content:

   ```
   org.openhab.automation.jrubyscripting:gem_home=<OPENHAB_CONF>/automation/lib/ruby/gem_home
   org.openhab.automation.jrubyscripting:gems=openhab-scripting=~>4.0
   org.openhab.automation.jrubyscripting:rubylib=<OPENHAB_CONF>/automation/lib/ruby/personal
   ```

   Replace <openhab_base_dir> with your base dir. This configuration with the openhab-scripting gem specified with [pessimistic versioning](https://thoughtbot.com/blog/rubys-pessimistic-operator) will install any version of openhab-scripting greater than or equal to 4.0 but less than 5.0. On system restart if any (non-breaking) new versions of the library are available they will automatically be installed.
3. Install the latest JRuby Scripting Language Addon from [here](https://github.com/boc-tothefuture/openhab2-addons/releases) to the folder `<OPENHAB_HOME>/addons/`

## Upgrading

Depending on the versioning selected in the `jruby.cfg` file upgrading will either be automatic after a OpenHAB restart or manual.  For manual upgrades select the version of the gem exactly, for example:
`org.openhab.automation.jrubyscripting:gems=openhab-scripting=4.0.0`

Will install and stay at version 4.0.0, to upgrade to version 4.0.1, change the configuration:
`org.openhab.automation.jrubyscripting:gems=openhab-scripting=4.0.1`

To automatically upgrade, it is recommended to use pessimistic versioning:
`org.openhab.automation.jrubyscripting:gems=openhab-scripting=~>4.0`
This will install at least version 4.0 and on every restart will automatically install any version that is less than 5.0. This ensures that fixes and new features are available without introducing any breaking changes.
