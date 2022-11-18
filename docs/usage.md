# @title Usage

# Usage

## Loading the Scripting Library

To make all the features offered by this library available to your rule, the JRuby scripting addon needs to
be [configured](docs/installation.md#from-the-user-interface) to install the `openhab-jrubyscripting` gem and
require the `openhab/dsl` script. This will enable all the special methods for {OpenHAB::Core::Items Items},
{OpenHAB::Core::Things::Thing Things}, {OpenHAB::Core::Actions Actions}, {OpenHAB::Log Logging}, etc. that are documented here,
and the {OpenHAB::Core::Events::AbstractEvent event} properties documented for the 
{OpenHAB::DSL::Rules::Builder#run run execution blocks}.

## Creating File-Based Rules

1. Place Ruby rules files in `ruby/personal/` subdirectory for OpenHAB scripted automation.  See [OpenHAB documentation](https://www.openhab.org/docs/configuration/jsr223.html#script-locations) for parent directory location.
2. Put `require 'openhab/dsl'` at the top of any Ruby based rules file.

For details on the rules syntax, see {OpenHAB::DSL::Rules::Builder}.

## Creating Rules in Main UI

Rules can be created in the UI as well as in rules files, but some things are a bit different.
First of all, only the execution blocks need to be created in the script. All triggers and conditions
are created directly in the UI instead.

**To create a rule:**

1. Go to the Rules section in the UI and add a new rule.
2. Input a name for your rule, and configure the Triggers through the UI.
3. When adding an Action, select **Run script**, and then **Ruby**. A script editor will open where you can write your code.
4. When you are done, save the script and go back to complete the configuration.

## UI Rules vs File-based Rules

The following features of this library are only usable within file-based rules:

* `Triggers`: UI-based rules provide equivalent triggers through the UI.
* `Guards`: UI-based rules use `Conditions` in the UI instead. Alternatively it can be implemented inside the rule code.
* `Execution Blocks`: The UI-based rules will execute your JRuby script as if it's inside a {OpenHAB::DSL::Rules::Builder#run run execution blocks}. 
A special {OpenHAB::Core::Events::AbstractEvent event} variable is available within your code to provide it with additional information regarding the event. 
For more details see the {OpenHAB::DSL::Rules::Builder#run run execution blocks}.
* `delay`: There is no direct equivalent in the UI. It can be achieved using {OpenHAB::DSL.after timers}.
* `otherwise`: There is no direct equivalent in the UI. However, it can be implemented within the rule using an `if-else` block.
