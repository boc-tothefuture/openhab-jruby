# @title On Start

# on_start

Execute the rule on OpenHAB start up and whenever the script is reloaded.
It is useful to perform initialization routines, especially when combined with other triggers.

## Examples

```ruby
rule 'Ensure all security lights are on' do
  on_start
  run { Security_Lights << ON }
end
```
