# @title Installation

## Prerequisites

1. openHAB 3.3+
2. The JRuby Scripting Language Addon
3. This scripting library

## Installation

Configure the openHAB JRuby Automation to install the `openhab-jrubyscripting` Ruby gem and automatically 
insert the `require` statement at the beginning of your scripts (_optional_).

### From the user interface

1. Go to `Settings -> Add-ons -> Automation` and install the jrubyscripting automation addon following the [openHAB instructions](https://www.openhab.org/docs/configuration/addons.html) 
2. Go to `Settings -> Other Services -> JRuby Scripting`:
   * **Ruby Gems**: `openhab-jrubyscripting=~>5.0`
   * **Require Scripts**: `openhab/dsl` (not required, but recommended)

### Using files

1. Configure JRuby openHAB services
   
   Create a file called `jruby.cfg` in `<OPENHAB_CONF>/services/` with the following content:
   ```
   org.openhab.automation.jrubyscripting:gems=openhab-jrubyscripting=~>5.0
   # optional: uncomment the following line if you prefer not having to 
   # insert require 'openhab/dsl' at the top of your scripts.
   # org.openhab.automation.jrubyscripting:require=openhab/dsl
   ```

   This configuration with the openhab-jrubyscripting gem specified with [pessimistic versioning](https://thoughtbot.com/blog/rubys-pessimistic-operator) will install any version of openhab-jrubyscripting greater than or equal to 5.0 but less than 6.0. On system restart if any (non-breaking) new versions of the library are available they will automatically be installed.
2. Edit `<OPENHAB_CONF>/services/addons.cfg` and ensure that `jrubyscripting` is included in an uncommented `automation=` list of automations to install.  

## Upgrading

Depending on the versioning selected in the `jruby.cfg` or the gems list in the user interface, file upgrading will either be automatic after a openHAB restart or manual.  For manual upgrades select the version of the gem exactly, for example:
`org.openhab.automation.jrubyscripting:gems=openhab-jrubyscripting=5.0.0`

Will install and stay at version 5.0.0, to upgrade to version 5.0.1, change the configuration:
`org.openhab.automation.jrubyscripting:gems=openhab-jrubyscripting=5.0.1`

To automatically upgrade, it is recommended to use pessimistic versioning:
`org.openhab.automation.jrubyscripting:gems=openhab-jrubyscripting=~>5.0`
This will install at least version 5.0 and on every restart will automatically install any version that is less than 6.0. This ensures that fixes and new features are available without introducing any breaking changes.
