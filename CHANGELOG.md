JRuby OpenHAB Scripting Change Log

# [2.11.0](https://github.com/boc-tothefuture/openhab-jruby/compare/2.10.1...2.11.0) (2021-02-01)


### Features

* Add Duration.to_s ([b5b9c81](https://github.com/boc-tothefuture/openhab-jruby/commit/b5b9c8176f995ad996ac481c4c23c614bd5f54f7))

## 2.10.0
### Changed
- Library now released as a Ruby Gem

## 2.9.0
### Added
- Support OpenHAB Actions

## 2.8.1
### Fixed
- Fixed StringItem comparison against a string

## 2.8.0
### Added
- Support for accessing item metadata namespace, value, and configuration

## 2.7.0
### Added
- SwitchItem.toggle to toggle a SwitchItem similar to SwitchItem << !SwitchItem

## 2.6.1
### Fixed
- Race condition with `after` block
- Unknown constant error in certain cases uses `between` blocks

## 2.6.0
### Added
- `TimeOfDay.between?` to check if TimeOfDay object is between supplied range
### Fixed
- Reference in rules to TimeOfDay::ALL_DAY


## 2.5.1
### Fixed
- Corrected time of day parsing to be case insensitive
- Merge conflict

## 2.5.0
### Added
- `between` can be used throughout rules systems
#### Changed
- TimeOfDay parsing now supports AM/PM

## 2.4.0
### Added
- Support to allow comparison of TimeOfDay objects against strings
- Support for storing and restoring Item states

## 2.3.0
### Added
- Support for rule description

## 2.2.1
### Fixed
- `!` operator on SwitchItems now returns ON if item is UNDEF or NULL

## 2.2.0
### Added
- Support for thing triggers in rules

### Changed
- Updated docs to point to OpenHAB document for script locations

## 2.1.0 
### Added
- Timer delegate for 'active?', 'running?', 'terminated?'

## 2.0.1
### Fixed
- Logging of mod and/or inputs can cause an exception of they are nil
- Timers (after) now available inside of rules

### Changed
 - DSL imports now shared by OpenHAB module and Rules Module

## 2.0.0
### Added
- Timer delegate for `after` method that supports reschedule

### Changed
- **Breaking:** `after` now returns a ruby Timer delegate

## 1.1.0
### Added
- Added support for channels triggers to rules
 
### Changed
- Fixed documentation for changed/updated/receive_command options

## 1.0.0
### Changed
- **Breaking:** Changed commanded method for rules to received_command

## 0.2.0
### Added
- Ability to execute rules based on commands sent to items, groups and group members
- Ability to send updates from item objects

### Changed
- Fixed documentation for comparing dimensioned items against strings

## 0.1.0
### Added
- Support for item updates within rules languages
### Changed
- Installation instructions to specify using latest release rather than a specific version

## 0.0.1 
- Initial release
