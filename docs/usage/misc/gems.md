---
layout: default
title: Ruby Gems
nav_order: 2
has_children: false
parent: Misc
grand_parent: Usage
---

# Ruby Gems

[Bundler](https://bundler.io/) is integrated, enabling any [Ruby gem](https://rubygems.org/) compatible with JRuby to be used within rules. This permits easy access to the vast ecosystem libraries within the ruby community.  It would also create easy reuse of automation libraries within the OpenHAB community, any library published as a gem can be easily pulled into rules. 

Gems are available using the [inline bundler syntax](https://bundler.io/guides/bundler_in_a_single_file_ruby_script.html). The require statement can be omitted. 


```ruby
gemfile do
  source 'https://rubygems.org'
   gem 'json', require: false
   gem 'nap', '1.1.0', require: 'rest'
end

logger.info("The nap gem is at version #{REST::VERSION}")     
```