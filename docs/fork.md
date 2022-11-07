# @title Significant Changes From openhab-scripting

# Significant Changes From `openhab-scripting`

`openhab-jrubyscripting` is a fork of `openhab-scripting`. Many thanks to
@boc-tothefuture, @jimtng, and @pacive for their work on the latter. The
purpose of this fork is because I (@ccutrer) felt that I wanted to
significantly re-work some of the core structure of the gem to shed some of the
technical debt that had accumulated from organic growth, and to do so speedily
without waiting for full review from other contributors with limited time. That
said, here is a non-exhaustive list of significant departures from the original
gem:

 * Significant new features! In particular, see {OpenHAB::DSL::Items::Builder},
   {OpenHAB::DSL::Things::Builder}, and several new triggers in
   {OpenHAB::DSL::Rules::Builder}.
 * Dropping support for OpenHAB < 3.3.
 * The main require is now `require "openhab/dsl"` instead of just
   `require "openhab"`. The reason being to avoid conflicts if a gem gets
   written to access OpenHAB via REST API. It's probably preferred that you
   [configure automatic requires](docs/installation.md) for this file anyway.
 * Major re-organization of class structures. {OpenHAB::Core} now contains any
   classes that are mostly wrappers or extensions of OpenHAB::Core Java
   classes, while {OpenHAB::DSL} contains novel Ruby-only classes to that
   implement a Ruby-first manner of creating rules, items, and things.
 * As part of the re-organization from above, the definition of a "DSL method"
   that is publicly exposed and available for use has been greatly refined.
   Top-level DSL methods are only available on `main` (the top-level {Object}
   instance when you're writing code in a rules file and not in any other
   classes), and inside of other select additional DSL constructs. If you've
   written your own classes that need access to DSL methods, you either need
   to explicitly call them on {OpenHAB::DSL}, or mix that module into your
   class yourself. Additional internal and Java constants and methods should
   no longer be leaking out of the gem's public API.
 * {OpenHAB::Core::Items::GenericItem} and descendants can no longer be treated
   as the item's state. While convenient at times, it introduces many
   ambiguities on if the intention is to interact with the item or its state,
   and contortionist code attempting to support both use cases.
 * Semi-related to the above, the `#truthy?` method has been removed from any
   items the previously implemented it. Instead, be more explicit on what you
   mean - for example `Item.on?`. If you would like to use a similar structure
   with {StringItem}s, just [include the ActiveSupport gem](docs/gems.md)
   in your rules to get `#blank?` and `#present?` methods, and then you can
   use `Item.state.present?`.
 * Semi-related to the above, the {OpenHAB::DSL::Rules::Builder#only_if} and
   {OpenHAB::DSL::Rules::Builder#not_if} guards now _only_ take blocks. This
   just means where you previously had `only_if Item` you now write
   `only_if { Item.on? }`.
 * The top-level `groups` method providing access to only
   {OpenHAB::Core::Items::GroupItem}s has been removed. Use
   `items.grep(GroupItem)` if you would like to filter to only groups.
 * `OpenHAB::Core::Items::GenericItem#id` no longer exists; just use
   {OpenHAB::Core::Items::GenericItem#to_s} which does what `#id` used to do.
 * `states?(*items)` helper is gone. Just use `items.all?(:state?)`, or in
   the rare cased you used `states?(*items, things: true)`, use
   `items.all? { |i| i.state? && i.things.all?(&:online?) }`.
 * {OpenHAB::Core::Items::GroupItem} is no longer {Enumerable}, and you must
   use {OpenHAB::Core::Items::GroupItem#members}.
 * {OpenHAB::Core::Items::GroupItem#all_members} no longer has a `filter`
   parameter; use `grep` if you want just {OpenHAB::Core::Items::GroupItem}s.
 * Triggers (such as {OpenHAB::DSL::Rules::Builder#changed} that previously
   took a splat _or_ an Array of Items now _only_ take a splat. This just
   means instead of `changed [Item1, Item2]` you write `changed Item1, Item2`,
   or if you have an actual array you write `change *item_array`.
   This greatly simplifies the internal code that has to distinguish between
   {OpenHAB::Core::Items::GroupItem::Members} and other types of
   collections of items.
 * Logging has been reworked. There's generally no need to
   `include OpenHAB::Log` in your classes. {OpenHAB::Log.logger} method now
   accepts a String to explicitly find whichever logger you would like, and
   {OpenHAB::Logger#level=} can be used to dynamically change the log level.
   Issues around the logger name while a rule is executing have also been
   resolved: the top-level `logger` will be named after the file, and the
   `logger` within a `rule` or execution block will be named after the rule.
   Loggers within class or instance-of-a-class context will be named after
   the class. These loggers will _not_ have their name changed simply because
   their methods happened to be called while a rule is executing.
 * The documentation philosophy has changed. Instead of relying on a large
   set of markdown files to give both commentary and to document the details
   of objects, [YARD](https://yardoc.org/) is now the primary generator
   of the documentation site. Details of individual objects and methods are
   now documented inline with the code, reducing duplication, aiding in
   keeping them up-to-date and accurate, and being more rigorous in ensuring
   the documentation has every available method listed, and in a consistent
   manner. Some commentary and high level examples (such as this file) are
   still maintained as dedicated markdown files, but included in the YARD
   docs, instead of being a separate site that then links to the YARD docs.
 * The testing philosophy has also changed. The
   [rspec-openhab-scripting gem](https://rubygems.org/gems/rspec-openhab-scripting),
   previously written as an independent project by me (@ccutrer), has now
   been merged into this gem. There is a tight interdependence between the two,
   and especially during the large refactoring it's much easier to have them
   in the same repository. This means that that gem is now the endorsed method
   to write tests for end-user rules, as well as the preferred way to write
   tests for this gem itself, when possible.
