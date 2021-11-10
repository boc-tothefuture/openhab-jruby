JRuby OpenHAB Scripting Change Log

## [4.13.4](https://github.com/boc-tothefuture/openhab-jruby/compare/4.13.3...4.13.4) (2021-11-10)


### Bug Fixes

* **actions:** call to_s to accept item as an argument ([9f770b3](https://github.com/boc-tothefuture/openhab-jruby/commit/9f770b3cb9c0a8610b5e7154efab04406a0e35a8))
* **dev:** add mac M1 platform to Gemfile.lock ([76fdbfd](https://github.com/boc-tothefuture/openhab-jruby/commit/76fdbfd6ca8dc6d0d1eafaa086611d85ea0ecd95))

## [4.13.3](https://github.com/boc-tothefuture/openhab-jruby/compare/4.13.2...4.13.3) (2021-11-08)


### Bug Fixes

* **binding:** move gem home default and mkdirs ([a9ccf3f](https://github.com/boc-tothefuture/openhab-jruby/commit/a9ccf3f1db4d2335c1509ffe56c83242926e097c))

## [4.13.2](https://github.com/boc-tothefuture/openhab-jruby/compare/4.13.1...4.13.2) (2021-11-08)


### Bug Fixes

* **binding:** fix binding support for gem ugprades ([07a1668](https://github.com/boc-tothefuture/openhab-jruby/commit/07a16681864f49e9613673988bbad0e09fd3fcba))

## [4.13.1](https://github.com/boc-tothefuture/openhab-jruby/compare/4.13.0...4.13.1) (2021-11-07)


### Bug Fixes

* **month_day:** test between guards with Time instead of TimeOfDay ([65bf3b1](https://github.com/boc-tothefuture/openhab-jruby/commit/65bf3b159255b56a2446059aeda535002d51639f))

# [4.13.0](https://github.com/boc-tothefuture/openhab-jruby/compare/4.12.1...4.13.0) (2021-11-06)


### Bug Fixes

* **test:** test against jruby plugin that fixes 3.2M2 reload bug ([bb98cb0](https://github.com/boc-tothefuture/openhab-jruby/commit/bb98cb091a8fb79578fcd834922eebc33aac394e))


### Features

* **percenttype:** add PercentType#scale and PercentType#to_byte ([54d2ec3](https://github.com/boc-tothefuture/openhab-jruby/commit/54d2ec3cb7a84eac5bb0341911f9fe16da81d105)), closes [#350](https://github.com/boc-tothefuture/openhab-jruby/issues/350)

## [4.12.1](https://github.com/boc-tothefuture/openhab-jruby/compare/4.12.0...4.12.1) (2021-11-06)


### Bug Fixes

* **dev:** target ruby 2.6 ([cdd3ea1](https://github.com/boc-tothefuture/openhab-jruby/commit/cdd3ea1c75c950b807a56f68cbd78ad68c59939d))
* **quantity:** fix comparison between integer on left and quantity on right ([b7f7531](https://github.com/boc-tothefuture/openhab-jruby/commit/b7f753110332b71f8b665e22562e2a02d3c86614)), closes [#352](https://github.com/boc-tothefuture/openhab-jruby/issues/352)

# [4.12.0](https://github.com/boc-tothefuture/openhab-jruby/compare/4.11.2...4.12.0) (2021-11-06)


### Features

* **build:** test against jruby 9.3 ([690699d](https://github.com/boc-tothefuture/openhab-jruby/commit/690699d61911cc4e67a4bad0b37d7f43328cf73e))

## [4.11.2](https://github.com/boc-tothefuture/openhab-jruby/compare/4.11.1...4.11.2) (2021-11-06)


### Bug Fixes

* **metadata:** return ruby hash inside metadata enumerator ([4347aa9](https://github.com/boc-tothefuture/openhab-jruby/commit/4347aa98966561c12c32a6695d6acadd6cedb2bf))

## [4.11.1](https://github.com/boc-tothefuture/openhab-jruby/compare/4.11.0...4.11.1) (2021-11-06)


### Bug Fixes

* **reentrant_timer:** reset the timer duration to the latest call ([e8e8b66](https://github.com/boc-tothefuture/openhab-jruby/commit/e8e8b666080a6cf0b47a08e13b9d4dcc8f9a9cbc))

# [4.11.0](https://github.com/boc-tothefuture/openhab-jruby/compare/4.10.3...4.11.0) (2021-11-05)


### Features

* **between:** support for month-day ranges ([f059c59](https://github.com/boc-tothefuture/openhab-jruby/commit/f059c59a173d322270e1c3053c94dba531e3beaa))

## [4.10.3](https://github.com/boc-tothefuture/openhab-jruby/compare/4.10.2...4.10.3) (2021-11-04)


### Bug Fixes

* **timer:** check the argument to reschedule ([d1e895f](https://github.com/boc-tothefuture/openhab-jruby/commit/d1e895ff243f7160bd2f54cfce5925ba07fabfff))

## [4.10.2](https://github.com/boc-tothefuture/openhab-jruby/compare/4.10.1...4.10.2) (2021-11-03)


### Bug Fixes

* **test:** added test coverage for mixed type between guards ([9030b3f](https://github.com/boc-tothefuture/openhab-jruby/commit/9030b3f9ca57b66d5f6865b6cbf8f3b501432587))

## [4.10.1](https://github.com/boc-tothefuture/openhab-jruby/compare/4.10.0...4.10.1) (2021-11-02)


### Bug Fixes

* **type:** allow comparison against incompatible types ([4ef6b2d](https://github.com/boc-tothefuture/openhab-jruby/commit/4ef6b2d0017c82c74f4d0ce82a7fb7e91681770c)), closes [#328](https://github.com/boc-tothefuture/openhab-jruby/issues/328) [/github.com/jruby/jruby/blob/9.2.19.0/core/src/main/java/org/jruby/RubyRange.java#L755](https://github.com//github.com/jruby/jruby/blob/9.2.19.0/core/src/main/java/org/jruby/RubyRange.java/issues/L755) [/github.com/jruby/jruby/blob/a309a88614916621de4cc5dc3693f279dae58d0c/core/src/main/java/org/jruby/RubyNumeric.java#L640](https://github.com//github.com/jruby/jruby/blob/a309a88614916621de4cc5dc3693f279dae58d0c/core/src/main/java/org/jruby/RubyNumeric.java/issues/L640) [/github.com/ruby/ruby/blob/4fb71575e270092770951e6a69bf006c71fadb55/numeric.c#L477](https://github.com//github.com/ruby/ruby/blob/4fb71575e270092770951e6a69bf006c71fadb55/numeric.c/issues/L477)

# [4.10.0](https://github.com/boc-tothefuture/openhab-jruby/compare/4.9.0...4.10.0) (2021-11-02)


### Features

* **attachments:** adds attachments to triggers ([88d35c5](https://github.com/boc-tothefuture/openhab-jruby/commit/88d35c534d28b302e33c8e830b4bbe6763f57abe))

# [4.9.0](https://github.com/boc-tothefuture/openhab-jruby/compare/4.8.5...4.9.0) (2021-11-01)


### Features

* **guards:** guards only_if/not_if support arrays of items ([66cda53](https://github.com/boc-tothefuture/openhab-jruby/commit/66cda53ffec10a14b4c14931838c24e96bc655b1))

## [4.8.5](https://github.com/boc-tothefuture/openhab-jruby/compare/4.8.4...4.8.5) (2021-11-01)


### Bug Fixes

* **guard:** only_if/not_if should work on all item types ([1c717a8](https://github.com/boc-tothefuture/openhab-jruby/commit/1c717a81d18030ae60d935f4625fd3557e139754))

## [4.8.4](https://github.com/boc-tothefuture/openhab-jruby/compare/4.8.3...4.8.4) (2021-11-01)

## [4.8.3](https://github.com/boc-tothefuture/openhab-jruby/compare/4.8.2...4.8.3) (2021-10-31)


### Bug Fixes

* **triggers:** trigger methods return the trigger objects ([463a928](https://github.com/boc-tothefuture/openhab-jruby/commit/463a9283e195bd591504047b15ba7abc7b5ff264))

## [4.8.2](https://github.com/boc-tothefuture/openhab-jruby/compare/4.8.1...4.8.2) (2021-10-30)


### Bug Fixes

* **guards:** log exception and stack traces encountered when guard procs are executed ([68c5f4d](https://github.com/boc-tothefuture/openhab-jruby/commit/68c5f4dafb04779ac97e88c3612ab68443cf7377))

## [4.8.1](https://github.com/boc-tothefuture/openhab-jruby/compare/4.8.0...4.8.1) (2021-10-30)


### Bug Fixes

* **hsb:** fully qualify units class ([25196d5](https://github.com/boc-tothefuture/openhab-jruby/commit/25196d559f876521dc027546d071defb7c3a5b01))

# [4.8.0](https://github.com/boc-tothefuture/openhab-jruby/compare/4.7.1...4.8.0) (2021-10-29)


### Features

* **timer:** supports reentrant timers and timed commands for items ([08d8f16](https://github.com/boc-tothefuture/openhab-jruby/commit/08d8f16ab490a63e614415c1ecf057429acc4e45))

## [4.7.1](https://github.com/boc-tothefuture/openhab-jruby/compare/4.7.0...4.7.1) (2021-10-29)


### Bug Fixes

* **hsb:** convert csv strings to hsb value ([5aad833](https://github.com/boc-tothefuture/openhab-jruby/commit/5aad83310993e8d95b8e372cd257d572e81beb60))

# [4.7.0](https://github.com/boc-tothefuture/openhab-jruby/compare/4.6.2...4.7.0) (2021-10-27)


### Bug Fixes

* **changed:** changed trigger now supports multiple from values ([20bb64e](https://github.com/boc-tothefuture/openhab-jruby/commit/20bb64e01be2e4effc1886c02f4137375cea5725))
* **logging:** use the class name not "Class" for class-level loggers ([05b6217](https://github.com/boc-tothefuture/openhab-jruby/commit/05b62174729523e499f66c52d432fa4b913a59a5))


### Features

* **metadata:** allow assignment to existing metadata config ([02df58a](https://github.com/boc-tothefuture/openhab-jruby/commit/02df58aeea7bef3d75212476ddd615c30d2ac9d2))

## [4.6.2](https://github.com/boc-tothefuture/openhab-jruby/compare/4.6.1...4.6.2) (2021-10-24)


### Bug Fixes

* **number_item:** return false for number predicate methods when NULL ([f147277](https://github.com/boc-tothefuture/openhab-jruby/commit/f147277785f33fc7ab5d854a4fff0b9f786a2106))

## [4.6.1](https://github.com/boc-tothefuture/openhab-jruby/compare/4.6.0...4.6.1) (2021-10-24)


### Bug Fixes

* **timer:** cancel timers in a rule when rule is unloaded ([901a63e](https://github.com/boc-tothefuture/openhab-jruby/commit/901a63e59f5086b559fd84b1fdb2b13b3d4a7800))

# [4.6.0](https://github.com/boc-tothefuture/openhab-jruby/compare/4.5.0...4.6.0) (2021-10-20)


### Bug Fixes

* **quantity:** fix constructing quantity from numeric with | within rule ([42dbafb](https://github.com/boc-tothefuture/openhab-jruby/commit/42dbafb3e3cf634c1493ffd19b03fd0e03b07689)), closes [#319](https://github.com/boc-tothefuture/openhab-jruby/issues/319)
* **tests:** fix ensure_states tests fragility ([7a36c43](https://github.com/boc-tothefuture/openhab-jruby/commit/7a36c43f583068a3e9489b0199ce0c02d0581c2c)), closes [#304](https://github.com/boc-tothefuture/openhab-jruby/issues/304)


### Features

* **location:** support location items ([ceb224a](https://github.com/boc-tothefuture/openhab-jruby/commit/ceb224aa0e8dfd0d82910ac3eb780d8f11e78c00)), closes [#37](https://github.com/boc-tothefuture/openhab-jruby/issues/37)

# [4.5.0](https://github.com/boc-tothefuture/openhab-jruby/compare/4.4.0...4.5.0) (2021-10-19)


### Features

* **color:** support for color items and hsb type ([8f45492](https://github.com/boc-tothefuture/openhab-jruby/commit/8f454924247674e75eaaa8a93e90176fff1ead8e)), closes [#34](https://github.com/boc-tothefuture/openhab-jruby/issues/34)

# [4.4.0](https://github.com/boc-tothefuture/openhab-jruby/compare/4.3.0...4.4.0) (2021-10-19)


### Bug Fixes

* **actions:** fix say and play_media actions for PercentType change ([53d7e06](https://github.com/boc-tothefuture/openhab-jruby/commit/53d7e062ec09130cefe089c00f42c302ce745f02)), closes [#298](https://github.com/boc-tothefuture/openhab-jruby/issues/298)
* **docs:** added docs for ensure/ensure_state ([77904b1](https://github.com/boc-tothefuture/openhab-jruby/commit/77904b16288efc3b7b9d2eac470ffa128d109bb3))


### Features

* **ensure:** add ensure_states feature ([b06385b](https://github.com/boc-tothefuture/openhab-jruby/commit/b06385bb9be81ffdb42c86156e6f4b184a498710)), closes [#275](https://github.com/boc-tothefuture/openhab-jruby/issues/275)

# [4.3.0](https://github.com/boc-tothefuture/openhab-jruby/compare/4.2.0...4.3.0) (2021-10-19)


### Bug Fixes

* **null_comparison:** fix comparison between two number items in state NULL ([b3bf156](https://github.com/boc-tothefuture/openhab-jruby/commit/b3bf1563c0dddd2246b0060ded8a34df84794e4c)), closes [#298](https://github.com/boc-tothefuture/openhab-jruby/issues/298)


### Features

* **rules:** add terse rule syntax for simple rules ([1c4b774](https://github.com/boc-tothefuture/openhab-jruby/commit/1c4b7744553679f1296428e765d04dbc57cfe99c))

# [4.2.0](https://github.com/boc-tothefuture/openhab-jruby/compare/4.1.4...4.2.0) (2021-10-18)


### Features

* **types:** allow comparison and arithmetic directly against state types ([22e237f](https://github.com/boc-tothefuture/openhab-jruby/commit/22e237fa93ae373fd63f05b9eaa17c0a78905939))

## [4.1.4](https://github.com/boc-tothefuture/openhab-jruby/compare/4.1.3...4.1.4) (2021-10-11)


### Bug Fixes

* **dev:** add binstubs for yard ([e2f8053](https://github.com/boc-tothefuture/openhab-jruby/commit/e2f8053452872df7f7fb26da41af2905ebe32426))
* **dev:** don't generate documentation when installing gem for tests ([995b8fc](https://github.com/boc-tothefuture/openhab-jruby/commit/995b8fcb8afad0f3546eb0500da40febcb47c956))

## [4.1.3](https://github.com/boc-tothefuture/openhab-jruby/compare/4.1.2...4.1.3) (2021-10-10)


### Bug Fixes

* **docs:** update installation docs to reference version 4.x of the gem ([c486cad](https://github.com/boc-tothefuture/openhab-jruby/commit/c486cad67e70483b2d3398116d79ce0778aafeec))

## [4.1.2](https://github.com/boc-tothefuture/openhab-jruby/compare/4.1.1...4.1.2) (2021-10-08)


### Bug Fixes

* **items:** restore ability to add items arrays together ([4b318c1](https://github.com/boc-tothefuture/openhab-jruby/commit/4b318c1d4e02fe2789a9f20fa198fb2f6ad629a2)), closes [#288](https://github.com/boc-tothefuture/openhab-jruby/issues/288)

## [4.1.1](https://github.com/boc-tothefuture/openhab-jruby/compare/4.1.0...4.1.1) (2021-10-07)


### Bug Fixes

* **dev:** update gemfile and binstubs for use with MRI ([7fe0027](https://github.com/boc-tothefuture/openhab-jruby/commit/7fe002715d3aa51378f3c72ddf4c63c3b4c20e1e))

# [4.1.0](https://github.com/boc-tothefuture/openhab-jruby/compare/4.0.1...4.1.0) (2021-10-06)


### Features

* **decimal_type:** zero?, positive?, negative? predicates directly on DecimalType ([bd69a76](https://github.com/boc-tothefuture/openhab-jruby/commit/bd69a763ec81e15bd4626264af4bc29a279d393c))

## [4.0.1](https://github.com/boc-tothefuture/openhab-jruby/compare/4.0.0...4.0.1) (2021-10-05)


### Performance Improvements

* **things, items:** improves performance on array accessors '[]' ([24bb04b](https://github.com/boc-tothefuture/openhab-jruby/commit/24bb04b34cc13ebbd4906fe547e31154d55e737c))

# [4.0.0](https://github.com/boc-tothefuture/openhab-jruby/compare/3.9.4...4.0.0) (2021-10-05)


### Features

* **command:** add predicate methods for named commands ([a347bb5](https://github.com/boc-tothefuture/openhab-jruby/commit/a347bb5942e28825a4be5e2adc450bd033b91e0a))
* **group_item:** alias items to members ([8e91ffc](https://github.com/boc-tothefuture/openhab-jruby/commit/8e91ffccc8d4f0dd2cc8a72aedd502459f140028))
* **states:** add predicate methods to several states ([5f987cc](https://github.com/boc-tothefuture/openhab-jruby/commit/5f987cc1ce7f86e8ab02b411635f55c8bbc4210f)), closes [#237](https://github.com/boc-tothefuture/openhab-jruby/issues/237)
* **types:** ensure (almost) all command types are inspectable ([2073072](https://github.com/boc-tothefuture/openhab-jruby/commit/2073072920a3becdb280d67048ab3fb2817e86eb))


* feat(events)!: wrap event.state same as item.state ([cbe6e5c](https://github.com/boc-tothefuture/openhab-jruby/commit/cbe6e5c275a30f84ca2ee3e32f1e3ae773b48e7e))


### BREAKING CHANGES

*  * event.state returns nil it's NULL or UNDEF.
 * event.last renamed to event.was (the predicate methods make much more
  sense calling it was instead of last, similar to Rail's tracking of
  changed attributes).
 * event.was returns nil if's NULL or UNDEF

## [3.9.4](https://github.com/boc-tothefuture/openhab-jruby/compare/3.9.3...3.9.4) (2021-09-25)


### Bug Fixes

* **build:** have release process keep Gemfile.lock up to date ([178cf4d](https://github.com/boc-tothefuture/openhab-jruby/commit/178cf4de37e7a50106697d43b33f673319a3c4ea))

## [3.9.3](https://github.com/boc-tothefuture/openhab-jruby/compare/3.9.2...3.9.3) (2021-09-25)

## [3.9.2](https://github.com/boc-tothefuture/openhab-jruby/compare/3.9.1...3.9.2) (2021-09-25)


### Bug Fixes

* **dev:** ignore lockfile for file named gems.rb ([8e31e0d](https://github.com/boc-tothefuture/openhab-jruby/commit/8e31e0d882a77c6a0422015ac5dd06c0b0c7ab9c))
* **release:** pin npm release versions to prevent build failures on upgrade of semantec release ([e1dc2a3](https://github.com/boc-tothefuture/openhab-jruby/commit/e1dc2a329e085ab7a0092762a0d3cd8c8df92737))

## [3.9.1](https://github.com/boc-tothefuture/openhab-jruby/compare/3.9.0...3.9.1) (2021-09-17)


### Bug Fixes

* **tests:** speed up tests by avoiding unnecessary work ([64c759c](https://github.com/boc-tothefuture/openhab-jruby/commit/64c759c9ee7b483f909db8e10b02467c0e3a6767))
* **tests:** speed up tests by forcing openhab to find rules ([d05a9e5](https://github.com/boc-tothefuture/openhab-jruby/commit/d05a9e51f15e7683b66ab52797ee2d4bd20a24ff))

# [3.9.0](https://github.com/boc-tothefuture/openhab-jruby/compare/3.8.3...3.9.0) (2021-09-17)


### Features

* **load_path:** apply $RUBYLIB ([29b6a34](https://github.com/boc-tothefuture/openhab-jruby/commit/29b6a34f050e82788f2e18d5de8e0025207de2c3))

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
