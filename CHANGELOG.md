JRuby OpenHAB Scripting Change Log

## [2.19.2](https://github.com/boc-tothefuture/openhab-jruby/compare/2.19.1...2.19.2) (2021-02-16)


### Bug Fixes

* **changed_duration:** guards not evaluated for changed duration ([48a63e8](https://github.com/boc-tothefuture/openhab-jruby/commit/48a63e82db6b82cdcf7a8855681db1fa65f23abc))

## [2.19.1](https://github.com/boc-tothefuture/openhab-jruby/compare/2.19.0...2.19.1) (2021-02-15)


### Bug Fixes

* **changed_duration:** cancel 'changed for' timer correctly ([1bf4aa3](https://github.com/boc-tothefuture/openhab-jruby/commit/1bf4aa390e8671e926fa44505cedd8f07d1d4260))

# [2.19.0](https://github.com/boc-tothefuture/openhab-jruby/compare/2.18.0...2.19.0) (2021-02-15)


### Features

* add RollershutterItem ([f5801d9](https://github.com/boc-tothefuture/openhab-jruby/commit/f5801d90b6998379db58c8462619d8f13332f0fa))

# [2.18.0](https://github.com/boc-tothefuture/openhab-jruby/compare/2.17.0...2.18.0) (2021-02-14)


### Features

* add DateTime Item type ([a3cc139](https://github.com/boc-tothefuture/openhab-jruby/commit/a3cc139d87b2df344bb1f0f78c3a68558e3e4fd5))

# [2.17.0](https://github.com/boc-tothefuture/openhab-jruby/compare/2.16.4...2.17.0) (2021-02-12)


### Features

* **units:** import OpenHAB common units for UoM ([351a776](https://github.com/boc-tothefuture/openhab-jruby/commit/351a77694fc89dcde9f93501324d91d03819fbd8))

## [2.16.4](https://github.com/boc-tothefuture/openhab-jruby/compare/2.16.3...2.16.4) (2021-02-12)


### Bug Fixes

* **changed_duration:** timer reschedule duration bug ([6bc8862](https://github.com/boc-tothefuture/openhab-jruby/commit/6bc8862f1d8b7631ef0ff79ac9599433e53a7259))

## [2.16.3](https://github.com/boc-tothefuture/openhab-jruby/compare/2.16.2...2.16.3) (2021-02-12)

## [2.16.2](https://github.com/boc-tothefuture/openhab-jruby/compare/2.16.1...2.16.2) (2021-02-11)


### Bug Fixes

* decorate items[itemname], event.item, and triggered item ([ce4ef03](https://github.com/boc-tothefuture/openhab-jruby/commit/ce4ef03afc3a9f10e96af17fccd61a0acf84cc4d))

## [2.16.1](https://github.com/boc-tothefuture/openhab-jruby/compare/2.16.0...2.16.1) (2021-02-11)


### Performance Improvements

* **timeofdayrangeelement:** subclass Numeric to make comparisons more efficient ([c2482e8](https://github.com/boc-tothefuture/openhab-jruby/commit/c2482e832fa3a4803bafef71217c6cfe1fdd2bed))

# [2.16.0](https://github.com/boc-tothefuture/openhab-jruby/compare/2.15.0...2.16.0) (2021-02-10)


### Features

* support comparisons between various numeric item/state types ([510d6db](https://github.com/boc-tothefuture/openhab-jruby/commit/510d6db9041afc91e261b43afd4d8e4b3ad135d3))

# [2.15.0](https://github.com/boc-tothefuture/openhab-jruby/compare/2.14.3...2.15.0) (2021-02-09)


### Features

* add Persistence support ([9cab1ff](https://github.com/boc-tothefuture/openhab-jruby/commit/9cab1ff24e2b2f87b0558385cd1c82d623547df6))

## [2.14.3](https://github.com/boc-tothefuture/openhab-jruby/compare/2.14.2...2.14.3) (2021-02-09)


### Bug Fixes

* multiple delayed triggers overwrite the previous triggers ([6f14429](https://github.com/boc-tothefuture/openhab-jruby/commit/6f14429113375907a39207bc25d75108897d61ca))

## [2.14.2](https://github.com/boc-tothefuture/openhab-jruby/compare/2.14.1...2.14.2) (2021-02-08)

## [2.14.1](https://github.com/boc-tothefuture/openhab-jruby/compare/2.14.0...2.14.1) (2021-02-05)


### Bug Fixes

* **number_item:** make math operations and comparisons work with Floats ([3b29aa9](https://github.com/boc-tothefuture/openhab-jruby/commit/3b29aa967f909e80400ed78406c680405b4974f4))

# [2.14.0](https://github.com/boc-tothefuture/openhab-jruby/compare/2.13.1...2.14.0) (2021-02-03)


### Features

* **logging:** append rule name to logging class if logging within rule context ([00c73a9](https://github.com/boc-tothefuture/openhab-jruby/commit/00c73a98de63eec31f7d2f24137e3581b6f66b60))

## [2.13.1](https://github.com/boc-tothefuture/openhab-jruby/compare/2.13.0...2.13.1) (2021-02-02)

# [2.13.0](https://github.com/boc-tothefuture/openhab-jruby/compare/2.12.0...2.13.0) (2021-02-02)


### Features

* **dimmeritem:** dimmeritems can now be compared ([aa286dc](https://github.com/boc-tothefuture/openhab-jruby/commit/aa286dcd8f55d7a7ecd84ed6b0e360cb52103a1c))

# [2.12.0](https://github.com/boc-tothefuture/openhab-jruby/compare/2.11.1...2.12.0) (2021-02-02)


### Bug Fixes

* return nil for items['nonexistent'] instead of raising an exception ([4a412f8](https://github.com/boc-tothefuture/openhab-jruby/commit/4a412f81daf46c86469d8badeac2327a6c1816d3))


### Features

* add Item.include? to check for item's existence ([1a8fd3a](https://github.com/boc-tothefuture/openhab-jruby/commit/1a8fd3aad11fb0549dc2c7308f26946ffb8e899c))

## [2.11.1](https://github.com/boc-tothefuture/openhab-jruby/compare/2.11.0...2.11.1) (2021-02-01)


### Bug Fixes

* **group:**  support for accessing triggering item in group updates ([6204f0a](https://github.com/boc-tothefuture/openhab-jruby/commit/6204f0a8f33e08abddcc130b46a2fe39c5f4bb49))

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
