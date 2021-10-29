---
layout: default
title: Actions
nav_order: 2
has_children: false
parent: Misc
grand_parent: Usage
---

# Actions

All OpenHAB's actions including those provided by add-ons are available, notably:
* Audio
* Voice
* Things
* Ephemeris
* Exec
* HTTP
* Ping

From add-ons, e.g.:
* Transformation
* PersistenceExtensions (from Persistence add-on)
* NotificationAction (from OpenHAB cloud add-on)

For convenience, the following methods are implemented:

| Method     | Parameters                                                    | Description                                                                                                                          |
|------------|---------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------|
| notify     | msg, email: (optional)                                        | When an email is specified, calls NotificationAction.sendNotification. Otherwise, calls NotificationAction.sendBroadcastNotification |
| say        | text, volume: (optional), voice: (optional), sink: (optional) | Calls Voice.say()                                                                                                                    |
| play_sound | filename, volume: (optional), sink: (optional)                | Calls Audio.playSound()                                                                                                              |

## Accessing thing-related actions
There are two methods to access thing related actions. 

The first method uses the `action` method and is analogous to how you load actions in the Jython helper libraries.  The second method takes advantage of the fact that actions are intrinsically attached to Things. 

### actions based

| Method  | Parameters       | Description                                                |
| ------- | ---------------- | ---------------------------------------------------------- |
| actions | scope, thing_uid | Return the Action object for the given scope and thing_uid |


```ruby
mail = actions('mail', 'mail:smtp:local')
mail.sendEmail('me@example.com', 'subject', 'message')
```


### things based

| Method | Parameters | Description                                               |
| ------ | ---------- | --------------------------------------------------------- |
| varies | varies     | Action methods delegated from thing to associated actions | 


```ruby
things['mail:smtp:local'].sendEmail('me@example.com', 'subject', 'message')
```


## Example

Run the TTS engine and output the default audio sink. For more information see [Voice](https://www.openhab.org/docs/configuration/multimedia.html#voice)
```ruby
rule 'Say the time every hour' do
  every :hour
  run { say "The time is #{TimeOfDay.now}" }
end
```

```ruby
rule 'Play an audio file' do
  every :hour
  run { play_sound "beep.mp3", volume: 100 }
end
```

Send a broadcast notification via the OpenHAB Cloud
```ruby
rule 'Send an alert' do
  changed Alarm_Triggered, to: ON
  run { notify 'Red Alert!' }
end
```

Send an email using the Mail binding
```ruby
rule 'Send an Email' do
  every :day
  run do
    mail = actions('mail', 'mail:smtp:local')
    mail.sendEmail('me@example.com', 'subject', 'message')
  end
end
```

Execute a command line
```ruby
rule 'Run a command' do
  every :day
  run do
    Exec.executeCommandLine('/bin/true')
  end
end
```
