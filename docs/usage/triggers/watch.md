# @title Watch Trigger

# watch

`watch` provides the ability to create a trigger on file and directory changes

| argument | Description                                                                                                                                          |
| -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
|          | Path to watch for changes, can be a directory or a file                                                                                              |
| glob:    | Limit events to paths matching this glob. Globs are matched using [File.fnmatch?](https://ruby-doc.org/core-2.6/File.html#method-c-fnmatch-3F) rules |
| for:     | Array of symbols to limit events to only specific change types, valid values are :created, :deleted, :modified                                       |


If a file or a path that does not exist is supplied as the argument to watch, the parent directory will be watched and the file or non-existent part of the supplied path will become the glob. For example, if the directory given is `/tmp/foo/bar` and `/tmp/foo` exists but `bar` does not exist inside of of `/tmp/foo` then the directory `/tmp/foo` will be watched for any files that match `*/bar`. 

If the last part of the path contains any glob characters e.g. `/tmp/foo/*bar`, the parent directory will be watched and the last part of the path will be treated as if it was passed as the `glob:` argument. 

In other words, `watch '/tmp/foo/*bar'` is equivalent to `watch '/tmp/foo', glob: '*bar'`


## Event

When an event is triggered to a rule, the event object has the following fields
| field      | Description                                                                                                                |
| ---------- | -------------------------------------------------------------------------------------------------------------------------- |
| path       | Ruby [Pathname](https://ruby-doc.org/stdlib-2.6.3/libdoc/pathname/rdoc/Pathname.html) object of the path that had an event |
| type       | Type of changes as a symbol, valid values are :created, :deleted, or :modified                                             |
| attachment | Attachment if supplied                                                                                                     |



## Examples

Watch `items` directory inside of the openhab configuration path and log any changes. `OpenHAB.conf_root` is available and is the path 
to the OpenHAB configuration directory as a Ruby pathname object.

```ruby
rule 'watch directory' do
  watch OpenHAB.conf_root/'items'
  run { |event| logger.info("#{event.path.basename} - #{event.type}") }
end
```

 Watch `items` directory for files that end in `*.erb` inside of the openhab configuration path and log any changes
```ruby
rule 'watch directory' do
  watch OpenHAB.conf_root/'items', glob: '*.erb'
  run { |event| logger.info("#{event.path.basename} - #{event.type}") }
end
```

Watch `items/foo.items` inside of the openhab configuration path and log any changes
```ruby
rule 'watch directory' do
  watch OpenHAB.conf_root/'items/foo.items'
  run { |event| logger.info("#{event.path.basename} - #{event.type}") }
end
```

Watch `items/*.items` inside of the openhab configuration path and log any changes
```ruby
rule 'watch directory' do
  watch OpenHAB.conf_root/'items/*.items'
  run { |event| logger.info("#{event.path.basename} - #{event.type}") }
end
```

Watch `items/*.items` inside of the openhab configuration path for when items files are deleted or created (ignore changes)
```ruby
rule 'watch directory' do
  watch OpenHAB.conf_root/'items/*.items', for: [:deleted, :created]
  run { |event| logger.info("#{event.path.basename} - #{event.type}") }
end
```

