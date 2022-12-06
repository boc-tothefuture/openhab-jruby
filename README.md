# openHAB JRuby Library

[![Gem Version](https://img.shields.io/gem/v/openhab-jrubyscripting)](https://rubygems.org/gems/openhab-jrubyscripting)
[![Continous Integration](https://github.com/ccutrer/openhab-jrubyscripting/workflows/Continuous%20Integration/badge.svg)](https://github.com/ccutrer/openhab-jrubyscripting/actions/workflows/ci.yml)
[![GitHub contributors](https://img.shields.io/github/contributors/ccutrer/openhab-jrubyscripting)](https://github.com/ccutrer/openhab-jrubyscripting/graphs/contributors)
[![EPLv2 License](https://img.shields.io/badge/License-EPLv2-blue.svg)](https://www.eclipse.org/legal/epl-2.0/)

This library aims to be a fairly high-level Ruby gem to support automation in openHAB.

Full documentation is available on [GitHub Pages](https://ccutrer.github.io/openhab-jrubyscripting/).

 * [Usage](USAGE.md)
 * [Changelog](CHANGELOG.md)
 * [Contributing](CONTRIBUTING.md)

## Installation

### Prerequisites

1. openHAB 3.3+
2. The JRuby Scripting Language Addon

### From the User Interface

1. Go to `Settings -> Add-ons -> Automation` and install the jrubyscripting automation addon following the [openHAB instructions](https://www.openhab.org/docs/configuration/addons.html)
2. Go to `Settings -> Other Services -> JRuby Scripting`:
   * **Ruby Gems**: `openhab-jrubyscripting=~>5.0`
   * **Require Scripts**: `openhab/dsl` (not required, but recommended)

### Using Files

1. Edit `<OPENHAB_CONF>/services/addons.cfg` and ensure that `jrubyscripting` is included in an uncommented `automation=` list of automations to install.  
2. Optionally configure JRuby openHAB services
   
   Create a file called `jruby.cfg` in `<OPENHAB_CONF>/services/` with the following content:
   ```
   org.openhab.automation.jrubyscripting:gems=openhab-jrubyscripting=~>5.0
   org.openhab.automation.jrubyscripting:require=openhab/dsl
   ```

   This configuration with the openhab-jrubyscripting gem specified with [pessimistic versioning](https://thoughtbot.com/blog/rubys-pessimistic-operator) will install any version of openhab-jrubyscripting greater than or equal to 5.0 but less than 6.0.
   On system restart if any (non-breaking) new versions of the library are available they will automatically be installed.

### Upgrading

Depending on the versioning selected in the `jruby.cfg` or the gems list in the user interface, file upgrading will either be automatic after a openHAB restart or manual.
For manual upgrades select the version of the gem exactly, for example, `org.openhab.automation.jrubyscripting:gems=openhab-jrubyscripting=5.0.0` will install and stay at version 5.0.0.
To upgrade to version 5.0.1, change the configuration: `org.openhab.automation.jrubyscripting:gems=openhab-jrubyscripting=5.0.1`.
To automatically upgrade, it is recommended to use pessimistic versioning: `org.openhab.automation.jrubyscripting:gems=openhab-jrubyscripting=~>5.0`/
This will install at least version 5.0 and on every restart will automatically install any version that is less than 6.0.
This ensures that fixes and new features are available without introducing any breaking changes.

## Design points
- Create an intuitive method of defining rules and automation
	- Rule language should "flow" in a way that you can read the rules out loud
- Abstract away complexities of openHAB
- Enable all the power of Ruby and openHAB
- Create a Frictionless experience for building automation
- The common, yet tricky tasks are abstracted and made easy. e.g. Running a rule between only certain hours of the day
- Tested
	- Designed and tested using [Test-Driven Development](https://en.wikipedia.org/wiki/Test-driven_development) with [RSpec](https://rspec.info/)
- Extensible
	- Anyone should be able to customize and add/remove core language features
- Easy access to the Ruby ecosystem in rules through Ruby gems. 

## Why Ruby?
- Ruby is designed for programmer productivity with the idea that programming should be fun for programmers.
- Ruby emphasizes the necessity for software to be understood by humans first and computers second.
- For me, automation is a hobby, I want to enjoy writing automation not fight compilers and interpreters .
- Rich ecosystem of tools, including things like Rubocop to help developers write clean code and RSpec to test the libraries.
- Ruby is really good at letting one express intent and creating a DSL within Ruby to make that expression easier.

## Fork from [openhab-scripting](https://github.com/boc-tothefuture/openhab-jruby/)

This gem is a fork. Thanks to [@boc-tothefuture](https://github.com/boc-tothefuture), [@jimtng](https://github.com/jimtng), and [@pacive](https://github.com/pacive) on the original gem.
See [Changes from openhab-scripting](CHANGELOG.md#5_0_0) for more details on the reasoning behind the fork, and the significant breaking changes.

## Discussion

Please see [this thread](https://community.openhab.org/t/jruby-openhab-rules-system/110598) on the openHAB forum for further discussion.
Ideas and suggestions are welcome.
