---
layout: default
title: Store States
nav_order: 6
has_children: false
parent: Misc
grand_parent: Usage
---

### store_states

store_states takes one or more items or groups and returns a map `{Item => State}` with the current state of each item. It is implemented by calling OpenHAB's [events.storeStates()](https://www.openhab.org/docs/configuration/actions.html#event-bus-actions).

```ruby
states = store_states Item1, Item2 
...
states.restore
```

or in a block context:
```ruby
store_states Item1, Item2 do
...
end # the states will be restored here
```

It can take an array of items:
```ruby
items_to_store = [ Item1, Item2 ]
states = store_states items_to_store
...
states.restore_changes # restore only changed items
```


The returned states variable is a hash that supports some additional methods:

| method          | description                                                                              |
| --------------- | ---------------------------------------------------------------------------------------- |
| restore         | Restores the states of all the stored items by calling events.restoreStates() internally |
| changed?        | Returns true if any of the stored items had changed states                               |
| restore_changes | restores only items whose state had changed    