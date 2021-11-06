---
layout: default
title: StringItem
nav_order: 5
has_children: false
parent: Items
grand_parent: Usage
---

# StringItem

| Method          | Parameters | Description                                                                | Example                                          |
| --------------- | ---------- | -------------------------------------------------------------------------- | ------------------------------------------------ |
| truthy?         |            | Item state not UNDEF, not NULL and is not blank ('') when trimmed.         | `puts "#{item.name} is truthy" if item.truthy?`  |
| String methods* |            | All methods for [Ruby String](https://ruby-doc.org/core-2.6.8/String.html) | `StringOne << StringOne + ' World!'`             |
| blank?          |            | True if state is UNDEF, NULL, string is empty or contains only whitespace  | `StringOne << StringTwo unless StringTwo.blank?` |

* All String methods returns a copy of the current state as a string.  Methods that modify a string in place, do not modify the underlying state string. 
 
 
## Examples

String operations can be performed directly on the StringItem

```ruby
# StringOne has a current state of "Hello"
StringOne << StringOne + " World!"
# StringOne will eventually have a state of 'Hello World!'

# Add Number item to 5
NumberOne << 5 + NumberOne

```

String Items can be selected in an enumerable with grep.

```ruby
# Get all StringItems
items.grep(StringItem)
     .each { |string| logger.info("#{string.id} is a String Item") }
```

String Item values can be matched against regular expressions

```ruby
# Get all Strings that start with an H
Strings.grep(/^H/)
        .each { |string| logger.info("#{string.id} starts with an H") }
```
