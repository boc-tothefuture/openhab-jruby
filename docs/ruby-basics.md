# @title Ruby Basics

# Ruby Basics

The OpenHAB JRuby scripting automation is based on the [JRuby](https://www.jruby.org/) implementation of the 
[Ruby](https://www.ruby-lang.org/) language. This page offers a quick overview of Ruby to help you get started
writing rules. However, it is by no means comprehensive. A wealth of information can be found on 
[Ruby's web site](https://www.ruby-lang.org/en/documentation/).

## Data Types

In Ruby, everything is an object, even primitive types such as numbers and strings. For example, `1` as a number is an object
and has all the methods for the [Integer class](https://ruby-doc.org/core-2.6/Integer.html).

It is useful to get to know the basic data types that we will often encounter:

* [Integer](https://ruby-doc.org/core-2.6/Integer.html) - e.g. `1`, `-3`, etc.
* [Floating Point](https://ruby-doc.org/core-2.6/Float.html) - e.g. `3.5`
* [String](https://ruby-doc.org/core-2.6/String.html) -
  String literals in Ruby can be enclosed with double quotes, or single quotes. Strings enclosed by double quotes can 
  contain variables and expressions that are enclosed with `#{}`. For example: `"Hi my name is #{name_variable}"`. The String class offers a plethora of useful methods to operate on and manipulate strings.
* [Array](https://ruby-doc.org/core-2.6/Array.html) - example: `[1, 2, 'foo', AnotherObject]`
* [Hash](https://ruby-doc.org/core-2.6/Hash.html) - example: `{ 'key1' => 'value', 'key2' => 'value' }`
* [Symbol](https://ruby-doc.org/core-2.6/Symbol.html) - example: `:iamasymbol`
* [Range](https://ruby-doc.org/core-2.6/Range.html) - example: `1..5`

## Variables

* In Ruby, variables start with a lower case and by convention use `snake_case`.
* Uppercase identifiers are constants, e.g. `NAMES`
* Variable whose names start with `$` are global variables, e.g. `$i_am_global`.
* Variable whose names start with `@` are instance variables, e.g. `@instance_variable`.
* Local variables are just plain names that starts with a lower case, e.g. `local_var`.
  
## Control Expressions

Ruby supports various [control expressions](https://ruby-doc.org/core-2.6.8/doc/syntax/control_expressions_rdoc.html) such as `if/else`, ternary operator, `case`, etc.

Example:

```ruby
if a
  # do something here
elsif b
  # something else
else 
  # something here
end

# modifier if form
a = b if c == 5

# ternary operator
a = b == 5 ? 'five' : 'other'

# case/when similar to the switch() { case... } in c / java.
rule 'x' do
  received_command DimmerItem1
  run do |event|
    case event.command
    when OFF
      Light1.off
      Light2.off
    when 0...50
      Light1.on
      Light2.off
    when 50..100, ON
      Light1.on
      Light2.on
    end
  end
end
```

## Loops

While Ruby supports the traditional `for` and `while` loop, they are rarely used. 
Ruby objects such as Array, Hash, Set, etc. provide a plethora of methods to
achieve the same thing in a more "Ruby" way.

### Examples

```ruby
array = [1, 2, 3]
array.each do |elem|
  logger.info("Element: #{elem}")
end

array.each_with_index do |elem, index|
  logger.info("Element #{index}: #{elem}")
end

SWITCH_TO_LIGHT_HASH = { Switch1: Light1, Switch2: Light2 }

SWITCH_TO_LIGHT_HASH.each do |switch, light|
  logger.info "#{switch.name} => #{light.name}"
end

rule 'turn light on' do
  changed Switches.members
  triggered do |item|
    SWITCH_TO_LIGHT_HASH[item]&.command item.state
  end
end
```

Note: `next` is similar to `continue` in C/Java. `break` in Ruby is the same as in C/Java.

## Blocks

Multi-line blocks in Ruby are enclosed in a `do` .. `end` pair and single line blocks are enclosed with braces `{` .. `}`. You have encountered blocks in the examples above.
Rules are implemented in a block:

```ruby
rule 'rulename' do
  ...
end
```

The execution part is also in a block for the run method, nested inside the rule block:

```ruby
rule 'rulename' do
  changed Item1
  run do 
    ...
  end
end
```

### Block arguments

Blocks can receive arguments which are passed by its caller. We will often encounter this in {OpenHAB::DSL::Rules::BuilderDSL#run run} and {OpenHAB::DSL::Rules::BuilderDSL#triggered triggered} blocks.

```ruby
rule 'name' do
  changed Switches.members
  run do |event|
    # do something based on the event argument
  end
end
```

## Ruby's Safe Navigation Operator

Ruby has a [safe navigation operator](https://ruby-doc.org/core-2.6/doc/syntax/calling_methods_rdoc.html#label-Safe+navigation+operator) 
`&.` which is similar to `?.` in C#, Groovy, Kotlin, etc.

```ruby
# Instead of:
if items['My_Item']
  items['My_Item'].on
end

# We can write it as:
items['My_Item']&.on
```


## Some Gotchas

### Exiting early 

To [exit early from a block](https://stackoverflow.com/questions/1402757/how-to-break-out-from-a-ruby-block), use `next` instead of `return`.

```ruby
rule 'rule name' do
  changed Item1
  run do 
    next if Item1.off? # exit early

    Item2.on # Turn on Item2 if Item1 turned on
    # Do other things
  end
end
```

Note: To exit early from a UI rule, use `return`.

### Parentheses

In Ruby, parentheses are optional when calling a method. However, when calling a method with arguments and a single-line block, 
the parentheses must be used. Example:

```ruby
after(5.seconds) {  }

after(5.seconds) do
  # ...
end

after 5.seconds do
  # parentheses aren't a must before a do..end block
end

# the following example will cause an error
after 5.seconds { }
```

### Zero is "truthy" in Ruby

```ruby
if 0
  logger.info "This will always be executed"
else
  logger.info "This will never be executed"
end
```

## Source Code Formatting

The [ruby style guide](https://rubystyle.guide) offers the generally accepted standards for Ruby source code formatting.

When working with file based rules in a source code editor (e.g. VSCode), it is highly recommended to integrate 
[Rubocop](https://rubocop.org/) (or [rubocop-daemon](https://github.com/fohte/rubocop-daemon))
as the source code formatter and linter for Ruby.

Happy coding!
