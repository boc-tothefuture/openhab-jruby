---
layout: default
title: ImageItem
nav_order: 1
has_children: false
parent: Items
grand_parent: Usage
---


# ImageItem

| Method            | Description                                                                                   | Options   | Example                                       |
| ----------------- | --------------------------------------------------------------------------------------------- | --------- | --------------------------------------------- |
| mime_type         | Get the mime type for the image                                                               |           | `item.mine_type`                              |
| bytes             | Get the bytes that comprise the image data                                                    |           | `item.bytes`                                  |
| update            | Update the image with with a base 64 encoded image data                                       |           | `item.update "data:image/png;base64,iVBO..."` |
| update_from_bytes | Update the image from a byte array, mime_type will be automatically detected unless specified | mime_type | `item.update_from_bytes [0,23,45]...`         |
| update_from_file  | Update the image from a file, mime_type will be automatically detected unless specified       | mime_type | `item.update_from_file '/tmp/foo.png'`        |
| update_from_url   | Update the image from a url                                                                   |           | `item.update_from_url 'https://www.foobar.com/baz.png'`        |


## Examples ##

Update from a base 64 encode image string

```ruby
Image.update "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABAQMAAAAl21bKAAAAA1BMVEUAAACnej3aAAAAAXRSTlMAQObYZgAAAApJREFUCNdjYAAAAAIAAeIhvDMAAAAASUVORK5CYII="
```

Update from image bytes and mime type

```ruby
Image.update_from_bytes IO.binread(File.join(Dir.tmpdir,'1x1.png')), mime\_type: 'image/png'
```

Update from URL

```ruby
Image.update_from_url 'https://raw.githubusercontent.com/boc-tothefuture/openhab-jruby/main/features/assets/1x1.png'
```


Update from File

```ruby
Image.update_from_file '/tmp/1x1.png'
```


Log image data
```ruby
logger.info("Mime type: #{Image.mime\_type}")
logger.info("Number of bytes: #{Image.bytes.length}")
```