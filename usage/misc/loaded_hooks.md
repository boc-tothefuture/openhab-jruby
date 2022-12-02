---
layout: default
title: Loaded / Unloaded Hooks
has_children: false
parent: Misc
grand_parent: Usage
---

# Loaded / Unloaded Hooks

| Method            | Description                                                                                                                                                     |
| ----------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `script_loaded`   | Add a block of code to be executed once the rule script has finished loading. This can occur on OpenHAB start up, when the script is first created, or updated. |
| `script_unloaded` | Add a block of code to be executed when the script is unloaded. This can occur when OpenHAB shuts down, or when the script is being reloaded.                   |

Multiple hooks can be added by calling `script_loaded` / `script_unloaded` multiple times. They can be used to perform final 
initializations (`script_loaded`) and clean up (`script_unloaded`).

Note: All timers created with `after` are cancelled by the scripting library automatically when the script is unloaded/reloaded, so it is not necessary to cancel them.

## Examples

```ruby
script_loaded do
  logger.info 'Hi, this script has just finished loading'
end

script_loaded do
  logger.info 'I will be called after the script finished loading too'
end

script_unloaded do
  logger.info 'Hi, this script has been unloaded'
end

rule 'x' do
  changed Item1
  run { logger.info("Item1 changed") }
end
```
