---
layout: default
title: Item Metadata
nav_order: 1
has_children: false
parent: Misc
grand_parent: Usage
---

# Item Metadata

Item metadata can be accessed through `Item.meta` using the hash syntax. The `Item.meta` variable is also an [Enumerable](https://ruby-doc.org/core-2.6.8/Enumerable.html).

In addition to the Enumerable methods, the following methods are available for `Item.meta`:

| Method     | Parameters               | Description                                           | Example                                     |
| ---------- | ------------------------ | ----------------------------------------------------- | ------------------------------------------- |
| clear      |                          | Deletes all metadata namespaces                       | `Item1.meta.clear`                          |
| delete     | namespace                | Delete the given namespace                            | `Item1.meta.delete 'namespace1'`            |
| dig        | key, *keys               | Dig through the namespace to find the specified value | `Item1.meta.dig('namespace1', 'foo', 'bar') |
| each       | namespace, value, config | Loops through all the item's namespaces               |                                             |
| merge!     | **other                  | Merge a hash or other item's metadata                 |                                             |
| namespace? | namespace                | Returns true if the given namespace exists            |                                             |

Metadata configuration is a hash and can be accessed using a subscript of `Item.meta['namespace']`. For example, the following Item metadata

```
Switch Item1 { namespace1="boo" [ config1="foo", config2="bar" ] }
```

is accessible via:

```ruby
Item1.meta['namespace1']['config1']
Item1.meta['namespace1']['config2']
```

The Item namespace has the following methods:

| Method | Parameters | Description                             | Example                                          |
| ------ | ---------- | --------------------------------------- | ------------------------------------------------ |
| delete | config_key | Delete the given metadata configuration | `Item1.meta['namespace1'].delete` 'config1'      |
| value  |            | Returns the namespace value             | `Item1.meta['namespace1'].value` # returns 'boo' |
| value= |            | Sets namespace value                    | `Item1.meta['namespace1'].value = 'moo'`         |

## Examples

With the following item definition:

```
Switch Item1 { namespace1="value" [ config1="foo", config2="bar" ] }
String StringItem1
```

```ruby
# Check namespace's existence
Item1.meta['namespace'].nil?
Item1.meta.key?('namespace')

# Access item's metadata value
Item1.meta['namespace1'].value

# Access namespace1's configuration
Item1.meta['namespace1']['config1']

# Safely search for the specified value - no errors are raised, only nil returned if a key
# in the chain doesn't exist
Item1.meta.dig('namespace1', 'config1') #=> 'foo'
Item1.meta.dig('namespace2', 'config1') #=> nil

# Set item's metadata value, preserving its config
# Item1's metadata before: { namespace1="value" [ config1="foo", config2="bar" ] }
Item1.meta['namespace1'].value = 'new value'
# Item1's metadata after: { namespace1="new value" [ config1="foo", config2="bar" ] }

# Set item's metadata config, preserving its value
# Item1's metadata before: { namespace1="value" [ config1="foo", config2="bar" ] }
Item1.meta['namespace1'].config = { 'scooby'=>'doo' }
# Item1's metadata after: { namespace1="value" [ scooby="doo" ] }

# Set a namespace to a new value and config in one line
# Item1's metadata before: { namespace1="value" [ config1="foo", config2="bar" ] }
Item1.meta['namespace1'] = 'new value', { 'scooby'=>'doo' }
# Item1's metadata after: { namespace1="new value" [ scooby="doo" ] }

# Set item's metadata value and clear its previous config
# Item1's metadata before: { namespace1="value" [ config1="foo", config2="bar" ] }
Item1.meta['namespace1'] = 'new value'
# Item1's metadata after: { namespace1="value" }

# Set item's metadata config, set its value to nil, and wiping out previous config
# Item1's metadata before: { namespace1="value" [ config1="foo", config2="bar" ] }
Item1.meta['namespace1'] = { 'newconfig' => 'value' }
# Item1's metadata after: { namespace1=nil [ config1="foo", config2="bar" ] }

# Update namespace1's specific configuration, preserving its value and other config
# Item1's metadata before: { namespace1="value" [ config1="foo", config2="bar" ] }
Item1.meta['namespace1']['config1'] = 'doo'
# Item1's metadata will be: { namespace1="value" [ config1="doo", config2="bar" ] }

# Add a new configuration to namespace1
# Item1's metadata before: { namespace1="value" [ config1="foo", config2="bar" ] }
Item1.meta['namespace1']['config3'] = 'boo'
# Item1's metadata after: { namespace1="value" [ config1="foo", config2="bar", config3="boo" ] }

# Delete a config
# Item1's metadata before: { namespace1="value" [ config1="foo", config2="bar" ] }
Item1.meta['namespace1'].delete('config2')
# Item1's metadata after: { namespace1="value" [ config1="foo" ] }

# Add a namespace and set it to a value
# Item1's metadata before: { namespace1="value" [ config1="foo", config2="bar" ] }
Item1.meta['namespace2'] = 'qx'
# Item1's metadata after: { namespace1="value" [ config1="foo", config2="bar" ], namespace2="qx" }

# Add a namespace and set it to a value and config
# Item1's metadata before: { namespace1="value" [ config1="foo", config2="bar" ] }
Item1.meta['namespace2'] = 'qx', { 'config1' => 'doo' }
# Item1's metadata after: { namespace1="value" [ config1="foo", config2="bar" ], namespace2="qx" [ config1="doo" ] }

# Enumerate Item1's namespaces
Item1.meta.each { |namespace, value, config| logger.info("Item1's namespace: #{namespace}='#{value}' #{config}") }

# Add metadata from a hash
Item1.meta.merge!({'namespace1' => [ 'foo', {'config1'=>'baz'} ], 'namespace2' => [ 'qux', {'config'=>'quu'} ]})

# Merge Item2's metadata into Item1's metadata
Item1.meta.merge! Item2.meta

# Delete a namespace
Item1.meta.delete('namespace1')

# Delete all metadata of the item
Item1.meta.clear

# Does this item have any metadata?
Item1.meta.any?

# Store another item's state
StringItem1.update 'TEST'
Item1.meta['other_state'] = StringItem1

# Store event's state
rule 'save event state' do
  changed StringItem1
  run { |event| Item1.meta['last_event'] = event.was }
end

# if the namespace already exists: Update the value of a namespace but preserve its config 
# otherwise: create a new namespace with the given value and nil config
Item1.meta['namespace'] = 'value', Item1.meta['namespace']

# Copy another namespace
# Item1's metadata before: { namespace2="value" [ config1="foo", config2="bar" ] }
Item1.meta['namespace'] = Item1.meta['namespace2']
# Item1's metadata after: { namespace2="value" [ config1="foo", config2="bar" ], namespace="value" [ config1="foo", config2="bar" ] }
```
