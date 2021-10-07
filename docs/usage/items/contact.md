---
layout: default
title: ContactItem
nav_order: 3
has_children: false
parent: Items
grand_parent: Usage
---

# ContactItem

| Method  | Description                          | Example                                   |
| ------- | ------------------------------------ | ----------------------------------------- |
| open?   | Returns true if item state == OPEN   | `puts "#{item} is closed." if item.open?` |
| closed? | Returns true if item state == CLOSED | `puts "#{item} is off." if item.closed`   |


##### Examples

`open?`/`closed?` checks state of contact

```ruby
# Log open contacts
Contacts.select(&:open?).each { |contact| logger.info("Contact #{contact.id} is open")}

# Log closed contacts
Contacts.select(&:closed?).each { |contact| logger.info("Contact #{contact.id} is closed")}

```

Contacts can be selected in an enumerable with grep.

```ruby
# Get all Contacts
items.grep(ContactItem)
     .each { |contact| logger.info("#{contact.id} is a Contact") }
```

Contacts states work in grep.

```ruby
# Log all open contacts in a group
Contacts.grep(OPEN)
        .each { |contact| logger.info("#{contact.id} is in #{contact}") }

# Log all closed contacts in a group
Contacts.grep(CLOSED)
        .each { |contact| logger.info("#{contact.id} is in #{contact}") }

```

Contact states work in case statements.

```ruby
#Log if contact is open or closed
case TestContact
when (OPEN)
  logger.info("#{TestContact.id} is open")
when (CLOSED)
  logger.info("#{TestContact.id} is closed")
end
```


Other examples

```ruby
rule 'Log state of all doors on system startup' do
  on_start
  run do
    Doors.each do |door|
      case door
      when OPEN then logger.info("#{door.id} is Open")
      when CLOSED then logger.info("#{door.id} is Open")
      else logger.info("#{door.id} is not initialized")
      end
    end
  end
end
```
