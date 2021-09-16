JRuby OpenHAB Scripting Change Log

## [3.8.3](https://github.com/boc-tothefuture/openhab-jruby/compare/3.8.2...3.8.3) (2021-09-16)


### Bug Fixes

* **docs:** make shields in readme actual links ([962eec7](https://github.com/boc-tothefuture/openhab-jruby/commit/962eec794e05ae0f4ac507dcf2f34b1a33ff085a))

## [3.8.2](https://github.com/boc-tothefuture/openhab-jruby/compare/3.8.1...3.8.2) (2021-09-15)


### Bug Fixes

* **dev:** add binstubs ([a425401](https://github.com/boc-tothefuture/openhab-jruby/commit/a425401ca5a588960a81ecaaf793be140c3a316f))

## [3.8.1](https://github.com/boc-tothefuture/openhab-jruby/compare/3.8.0...3.8.1) (2021-09-15)


### Bug Fixes

* **build:** commit the Gemfile.lock ([17def5c](https://github.com/boc-tothefuture/openhab-jruby/commit/17def5c097fd95cc844c8651e155cfdbe631b512))

# [3.8.0](https://github.com/boc-tothefuture/openhab-jruby/compare/3.7.4...3.8.0) (2021-09-15)


### Features

* **duration:** support duration methods on Float too ([fae9daf](https://github.com/boc-tothefuture/openhab-jruby/commit/fae9daf8b0dd0d3b854652a54663c4fb5d963cc8)), closes [#263](https://github.com/boc-tothefuture/openhab-jruby/issues/263)

## [3.7.4](https://github.com/boc-tothefuture/openhab-jruby/compare/3.7.3...3.7.4) (2021-09-15)


### Bug Fixes

* **test:** test against released version of openhab 3.1 and set default to 3.1 ([b8d09c1](https://github.com/boc-tothefuture/openhab-jruby/commit/b8d09c106ae708107ac75bcb66406b66e483b7ee))

## [3.7.3](https://github.com/boc-tothefuture/openhab-jruby/compare/3.7.2...3.7.3) (2021-09-15)


### Bug Fixes

* **build:** updated to new version of jruby scripting ([ae8b5a2](https://github.com/boc-tothefuture/openhab-jruby/commit/ae8b5a276676f6509e8862f73276997bafa38cd5))

## [3.7.2](https://github.com/boc-tothefuture/openhab-jruby/compare/3.7.1...3.7.2) (2021-09-14)


### Bug Fixes

* **docs:** remove duplicated "compare" in a few places ([2a9af7b](https://github.com/boc-tothefuture/openhab-jruby/commit/2a9af7b2ae4eed5668218d9ec01f4585369d6a3c))

## [3.7.1](https://github.com/boc-tothefuture/openhab-jruby/compare/3.7.0...3.7.1) (2021-09-14)


### Bug Fixes

* **test:** fix rubocop violations against newest rubocop ([e8b859b](https://github.com/boc-tothefuture/openhab-jruby/commit/e8b859b795ac57fb1873b199f2e7723313240433))

# [3.7.0](https://github.com/boc-tothefuture/openhab-jruby/compare/3.6.4...3.7.0) (2021-06-04)


### Features

* **quantity:** implement positive?, negative?, and zero? for quantity and dimensioned numberitem ([0d2c43c](https://github.com/boc-tothefuture/openhab-jruby/commit/0d2c43ca99db6abeef068adff7dca5f3bdf71703))

## [3.6.4](https://github.com/boc-tothefuture/openhab-jruby/compare/3.6.3...3.6.4) (2021-06-04)


### Bug Fixes

* **items:** decorated items could not be used as hash keys ([a4ff086](https://github.com/boc-tothefuture/openhab-jruby/commit/a4ff0869171ff10c1bae505fe3bc3af480d0cb54))

## [3.6.3](https://github.com/boc-tothefuture/openhab-jruby/compare/3.6.2...3.6.3) (2021-06-03)


### Bug Fixes

* improve reliability of some tests ([22bc48e](https://github.com/boc-tothefuture/openhab-jruby/commit/22bc48e677b2021c28366ca9b57b06ca91a10e54))

## [3.6.2](https://github.com/boc-tothefuture/openhab-jruby/compare/3.6.1...3.6.2) (2021-06-02)


### Bug Fixes

* **items:** format BigDecimal state as a string the parser accepts ([c752711](https://github.com/boc-tothefuture/openhab-jruby/commit/c752711b7057c819c1a372a9d35e1e85bf4c54b5))

## [3.6.1](https://github.com/boc-tothefuture/openhab-jruby/compare/3.6.0...3.6.1) (2021-06-02)

# [3.6.0](https://github.com/boc-tothefuture/openhab-jruby/compare/3.5.0...3.6.0) (2021-06-01)


### Features

* **build:** support testing of multiple versions of openhab ([600bc88](https://github.com/boc-tothefuture/openhab-jruby/commit/600bc88b281332f907948f65f59b11f7f66948c6))

# [3.5.0](https://github.com/boc-tothefuture/openhab-jruby/compare/3.4.3...3.5.0) (2021-06-01)


### Bug Fixes

* **store_states:** error when given a decorated item ([ae7e1bc](https://github.com/boc-tothefuture/openhab-jruby/commit/ae7e1bcf250a3bac18d080efc7b966397cb84279))


### Features

* add oh_item to item wrappers through def_item_delegator ([079314f](https://github.com/boc-tothefuture/openhab-jruby/commit/079314f3c9213e5e0b3d29e2824a22e2c36d8a0b))

## [3.4.3](https://github.com/boc-tothefuture/openhab-jruby/compare/3.4.2...3.4.3) (2021-05-20)


### Bug Fixes

* **build:** updated version of OpenHab ([ef1b792](https://github.com/boc-tothefuture/openhab-jruby/commit/ef1b7923e10ba67800eef7aae32b3d5eb0d5e729))

## [3.4.2](https://github.com/boc-tothefuture/openhab-jruby/compare/3.4.1...3.4.2) (2021-04-02)


### Bug Fixes

* **metadata:** convert loaded metadata config into Ruby objects ([aa8e2b7](https://github.com/boc-tothefuture/openhab-jruby/commit/aa8e2b78987d792d6b2299df6e262e68716827ca))

## [3.4.1](https://github.com/boc-tothefuture/openhab-jruby/compare/3.4.0...3.4.1) (2021-04-02)


### Bug Fixes

* **dependency:** swapped mimemagic for marcel for mime type detection ([b1ec891](https://github.com/boc-tothefuture/openhab-jruby/commit/b1ec8915a05dff6236677df1a0e3e115b8cb0d51))

# [3.4.0](https://github.com/boc-tothefuture/openhab-jruby/compare/3.3.0...3.4.0) (2021-03-22)


### Features

* **thing:** add boolean methods for checking thing's status ([58bda12](https://github.com/boc-tothefuture/openhab-jruby/commit/58bda12449d72c7ac1d8e1ee1d7c2876897a0851))

# [3.3.0](https://github.com/boc-tothefuture/openhab-jruby/compare/3.2.1...3.3.0) (2021-03-16)


### Features

* **persistence:** convert HistoricItem methods to directly return its state ([942d7ea](https://github.com/boc-tothefuture/openhab-jruby/commit/942d7ea22edafc697b5a3bf8c222a1ecb1860551))

## [3.2.1](https://github.com/boc-tothefuture/openhab-jruby/compare/3.2.0...3.2.1) (2021-03-11)


### Bug Fixes

* handle native java exceptions in clean_backtrace ([a6f7be4](https://github.com/boc-tothefuture/openhab-jruby/commit/a6f7be47c476e43fb7e3fd146fb02d4c07b6fc4a))

# [3.2.0](https://github.com/boc-tothefuture/openhab-jruby/compare/3.1.2...3.2.0) (2021-03-10)


### Features

* support more comparisons ([3898d2d](https://github.com/boc-tothefuture/openhab-jruby/commit/3898d2da40994e322ffb2773fe35184debf0d261))

## [3.1.2](https://github.com/boc-tothefuture/openhab-jruby/compare/3.1.1...3.1.2) (2021-03-09)


### Bug Fixes

* **scope:** change execution block binding to be object that based a block to rule ([b529684](https://github.com/boc-tothefuture/openhab-jruby/commit/b5296844e6a677452388dfb70e743f18a66d3fd6))

## [3.1.1](https://github.com/boc-tothefuture/openhab-jruby/compare/3.1.0...3.1.1) (2021-03-08)


### Bug Fixes

* **rollershutter_item:** add safe navigation and nil checks ([1e98464](https://github.com/boc-tothefuture/openhab-jruby/commit/1e984646d50f97fd3ccd933e548c08e4f8290704))

# [3.1.0](https://github.com/boc-tothefuture/openhab-jruby/compare/3.0.1...3.1.0) (2021-03-08)


### Features

* **image:** support for image items ([dacc7a8](https://github.com/boc-tothefuture/openhab-jruby/commit/dacc7a8531dcbe256c16a7ac8685ecb0c7e5dcc1))

## [3.0.1](https://github.com/boc-tothefuture/openhab-jruby/compare/3.0.0...3.0.1) (2021-03-03)


### Bug Fixes

* triggering on multiple items caused a stack overflow ([a1fac1d](https://github.com/boc-tothefuture/openhab-jruby/commit/a1fac1d84269fb462acd8e378c8f5f460e2d447b))

# [3.0.0](https://github.com/boc-tothefuture/openhab-jruby/compare/2.27.1...3.0.0) (2021-03-02)


### Features

* **groups:** groups now act as items ([210e507](https://github.com/boc-tothefuture/openhab-jruby/commit/210e50721adbf908a2f888cae7f46fc1687be4f9))


### BREAKING CHANGES

* **groups:** `items` no longer acts as a indicator to rules to
trigger on member changes, it has been replaced with `members`

## [2.27.1](https://github.com/boc-tothefuture/openhab-jruby/compare/2.27.0...2.27.1) (2021-03-02)

# [2.27.0](https://github.com/boc-tothefuture/openhab-jruby/compare/2.26.1...2.27.0) (2021-03-02)


### Features

* **player:** add support for player items ([70418ab](https://github.com/boc-tothefuture/openhab-jruby/commit/70418abfa0c504ed819e15c0508ad05e486fcf0d))

## [2.26.1](https://github.com/boc-tothefuture/openhab-jruby/compare/2.26.0...2.26.1) (2021-03-02)


### Performance Improvements

* **logging:** use block syntax to log method calls ([9657e72](https://github.com/boc-tothefuture/openhab-jruby/commit/9657e72c4d80b2c7adb722de428b830efb75e75f))

# [2.26.0](https://github.com/boc-tothefuture/openhab-jruby/compare/2.25.2...2.26.0) (2021-03-02)


### Features

* add stack trace to errors ([572114e](https://github.com/boc-tothefuture/openhab-jruby/commit/572114e74f688bc85925f0f33d2cf0bc3e06d4f8))

## [2.25.2](https://github.com/boc-tothefuture/openhab-jruby/compare/2.25.1...2.25.2) (2021-02-28)


### Performance Improvements

* **datetime:** delegate more methods directly to ZonedDateTime ([ea31954](https://github.com/boc-tothefuture/openhab-jruby/commit/ea3195402b5c4179090feafaba2d53476342251d))

## [2.25.1](https://github.com/boc-tothefuture/openhab-jruby/compare/2.25.0...2.25.1) (2021-02-28)

# [2.25.0](https://github.com/boc-tothefuture/openhab-jruby/compare/2.24.0...2.25.0) (2021-02-24)


### Features

* **groups:** support command and << ([dd140aa](https://github.com/boc-tothefuture/openhab-jruby/commit/dd140aa6f28f6138e197fdc2274f960ff304664e))

# [2.24.0](https://github.com/boc-tothefuture/openhab-jruby/compare/2.23.3...2.24.0) (2021-02-23)


### Features

* **groups:** adds supports for item groups ([127ab17](https://github.com/boc-tothefuture/openhab-jruby/commit/127ab17a69ec2ff2eac8674bba1c3ee2102a4fa9))

## [2.23.3](https://github.com/boc-tothefuture/openhab-jruby/compare/2.23.2...2.23.3) (2021-02-21)


### Bug Fixes

* **persistence:** selective conversion to Quantity ([3187de7](https://github.com/boc-tothefuture/openhab-jruby/commit/3187de7bdb1bea47e8ba8d288332da5c227e3892))

## [2.23.2](https://github.com/boc-tothefuture/openhab-jruby/compare/2.23.1...2.23.2) (2021-02-21)

## [2.23.1](https://github.com/boc-tothefuture/openhab-jruby/compare/2.23.0...2.23.1) (2021-02-20)

# [2.23.0](https://github.com/boc-tothefuture/openhab-jruby/compare/2.22.1...2.23.0) (2021-02-20)


### Bug Fixes

* **metadata:** convert value to string before assignment ([dba5db7](https://github.com/boc-tothefuture/openhab-jruby/commit/dba5db7d56f25ea279723c653c154c65c3fe030a))


### Features

* **event:** add event.state for update trigger ([d4eb4f7](https://github.com/boc-tothefuture/openhab-jruby/commit/d4eb4f78043ac108e54c0491affb72b383397b45))

## [2.22.1](https://github.com/boc-tothefuture/openhab-jruby/compare/2.22.0...2.22.1) (2021-02-20)


### Bug Fixes

* **changed:** for parameter with thing chaged trigger ([cd08922](https://github.com/boc-tothefuture/openhab-jruby/commit/cd08922fe7c9f4b2687b0b19000ecc3ba687bc9e))

# [2.22.0](https://github.com/boc-tothefuture/openhab-jruby/compare/2.21.0...2.22.0) (2021-02-19)


### Features

* add conversion operator for DecimalType to Quantity ([42bc5de](https://github.com/boc-tothefuture/openhab-jruby/commit/42bc5de8321d6e5b4554afd84fd5759d672bf992))

# [2.21.0](https://github.com/boc-tothefuture/openhab-jruby/compare/2.20.3...2.21.0) (2021-02-18)


### Features

* **persistence:** automatically convert to quantity for dimensioned items ([7e352d4](https://github.com/boc-tothefuture/openhab-jruby/commit/7e352d4cc1b4ff8ab50e409cf0ef56f4a6d74fae))

## [2.20.3](https://github.com/boc-tothefuture/openhab-jruby/compare/2.20.2...2.20.3) (2021-02-18)


### Bug Fixes

* **changed_duration:** stringitem from/to comparison didn't work ([21721e7](https://github.com/boc-tothefuture/openhab-jruby/commit/21721e74a7595de83d94cd2a9143ebde4b36938b))

## [2.20.2](https://github.com/boc-tothefuture/openhab-jruby/compare/2.20.1...2.20.2) (2021-02-18)

## [2.20.1](https://github.com/boc-tothefuture/openhab-jruby/compare/2.20.0...2.20.1) (2021-02-18)


### Bug Fixes

* **items:** to_s did not include UNDEF and NULL ([71f3de4](https://github.com/boc-tothefuture/openhab-jruby/commit/71f3de4c1f3fde6412ebe1748550a62e989187e0))

# [2.20.0](https://github.com/boc-tothefuture/openhab-jruby/compare/2.19.3...2.20.0) (2021-02-18)


### Features

* add dig-method to top level metadata ([2975cd5](https://github.com/boc-tothefuture/openhab-jruby/commit/2975cd565fb7dbf8c994fcb306d40ae75f2e8c03))

## [2.19.3](https://github.com/boc-tothefuture/openhab-jruby/compare/2.19.2...2.19.3) (2021-02-18)


### Bug Fixes

* **rule:** otherwise blocks are always executed ([dd5d5e5](https://github.com/boc-tothefuture/openhab-jruby/commit/dd5d5e5cd6a6eb02b57e5e70d34a27e512bc0d0e))

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
