# @title Valid State

# state?

`state?` returns true if all the given items have a valid state (not UNDEF or NULL).

| Parameter | Description                                                                                                                                                              |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `items`   | One or more items to check                                                                                                                                               |
| `things:` | Default: `false` - do not check for linked things status. When `things:` is set to `true`, only return true when all things linked to the items are in the ONLINE state. |

## Examples

```ruby
if state? Item1, Item2 
  average = (Item1 + Item2)/2 # Neither Item1 nor Item2 is UNDEF/NULL
end
```

or in a rule guard

```ruby
rule 'calculate' do
  changed Item1, Item2
  only_if { state? Item1, Item2 }
  run { logger.info "Average of Item1 and Item2: #{(Item1 + Item2) / 2}}" }
end
```

It can take an array of items:

```ruby
calculated_items = [ Item1, Item2 ]

rule 'calculate' do
  changed calculated_items
  only_if { state? calculated_items }
  run { logger.info "Sum of Item1 and Item2: #{calculated_items.sum}" }
end
```
