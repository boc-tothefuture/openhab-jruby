# frozen_string_literal: true

# require "#{__dir__}/../conf/automation/lib/ruby/openhab"
require 'openhab'

def bathtub_timer
  @bathtub_timer ||= Timer.new(duration: 15.minutes) do |timer|
    if BathTub_Light.on? && MasterBathRoom_ExhaustFan.on? 
      timer.reschedule
    elsif BathTub_Light.on?
      BathTub_Light.off 
      @bathtub_timer = nil
    else 
      @bathtub_timer = nil
    end
  end
end

rule 'Bathtub Light Auto-Off' do
  changed BathTub_Light
  run do |event|
    case event.state
    when ON then bathtub_timer.reschedule
    when OFF 
      @bathtub_timer&.cancel
      @bathtub_timer = nil
  end
end

rule 'Reset Bathtub Timer' do
  changed MasterBathRoom_ExhaustFan, to: OFF
  changed [MasterBedRoom_Motion, MasterBathRoom_Motion], to: OPEN
  run { @bathtub_timer&.reschedule }
  only_if BathTub_Light
end




# extend OpenHAB

# rubocop:disable Style/BlockComments

# debug_variables

# puts VirtualSwitch
# pp VirtualSwitch
# puts lowerSwitch

# logger.info 'Before Timer'
# after(30.seconds) { logger.info 'Hello From Timer?' }
# logger.info 'After Timer'

# puts Switches.class

# VirtualString.state = "Cat"
# after(5.seconds) { puts VirtualString }

# Design points
# Create an intuitive method of defining rules and automation
# Abstract away complexities of Openhab (Timers, Item.state vs Item)
# Enable all the power of Ruby and OpenHab
# Create a 'Frictionaless' experience for building automation

# Why Ruby?
# It was designed for programmer productivity with the idea that programming should be fun for programmers.
# It emphasizes the necessity for software to be understood by humans first and computers second.
#
# For me automation is a hobby, I want to enjoy writing automation not fight compilers.
#
# Rich ecosystem, including Rubocop to help developers create good code.
#
# Ruby is really good at letting you express yourself and creating a DSL within ruby (that is still ruby) to make expression easier.

# Notes:
# All items and groups are automatically available, no need to "getItem"
# List of items are avilable as "items" and do not include groups
# List of groups are avilable as "groups"
# While conceptionaly in openhab they are stored as items, their uses are quite different in most cases and you don't use them interchangably.

# Simple Syntax
# rule 'name' do
#   <one of many triggers>
#   run do
#      <automation code goes here>
#   end
# end

# Full syntax for all of the properties that are available to the rule resource is.
# rule 'name' do
#   every                               Symbol (:second, :minute, :hour, :day, :week, :month, :year) or duration (Integer.minutes, Integers.seconds, Integer.hours)
#   cron                                String (OpenHab Cron Expression )
#   changed (from: STATE, to: STATE)    Item or Group or [Group.all_members or maybe Group.*]  (Group syntax isn't finalized yet)
#   updated^                            Item or Group or [Group.all_members or maybe Group.*]  (Group syntax isn't finalized yet)
#   command^                            Item or Group or [Group.all_members or maybe Group.*]  (Group syntax isn't finalized yet)
#   on_start^
#   triggered CHANNEL (event: EVENT)
#
#   run do |event|                      Block of automation to run
#      <automation>
#   end
#   delay                               non-blocking delay Duration
#   only_if                             Item(s) or Group(s) or Block
#   not_if                              Item(s) or Group(s) or Block
#   enabled [true]                      If true [default] this rule is run, otherwise it is disabled.
#
#
#
#  ... These properties can be repeated as many times as you want
# end

# ^not developed yet

# WIP/Evaluations
# Adding a "switch" property that dynamically creates a switch to enable or disable an automation
#
#  rule 'Simple' do
#   every :minute
#   run { logger.info "Rule #{name} executed" }
#  end
#
# rule 'Turn off any switch that changes' do
#   changed(*Switches)
#   triggered(&:off)
#   enabled false
# end
#
# rule 'Turn off any switch that changes 2' do
#   changed Switches.items
#   run { |event| event.item.off }
#   enabled false
# end
#
# rule 'Log whenever a Virtual Switch Changes' do
#   items.select { |item| item.is_a? Switch }
#        .select { |item| item.label&.include? 'Virtual' }
#        .each do |item|
#          changed item
#        end
#
#   run { |event| logger.info "#{event.item} changed from #{event.last} to #{event.state}" }
#   enabled false
# end
#
# virtual_switches = items.select { |item| item.is_a? Switch }
#                         .select { |item| item.label&.include? 'Virtual' }
#
# rule 'Log whenever a Virtual Switch Changes 2' do
#   changed virtual_switches
#   run { |event| logger.info "#{event.item} changed from #{event.last} to #{event.state} 2" }
#   enabled false
# end
#
# virtual_switches.each do |switch|
#   rule "Log whenever a #{switch.label} Changes" do
#     changed switch
#     run { |event| logger.info "#{event.item} changed from #{event.last} to #{event.state} 2" }
#     enabled false
#   end
# end
#
#
#
# rule 'Dim a switch on system startup over 100 seconds' do
#   on_start
#   100.times do
#     run { DimmerSwitch.dim }
#     delay 1.second
#   end
# end
#

# rule 'Turn a Dimmer on and then dim by 5, pausing every second, at system start' do
#   on_start
#   run { DimmerSwitch << ON }
#   delay 5.seconds
#   dim_by = 5
#   (100 / dim_by).times do
#     run { DimmerSwitch -= dim_by }
#     delay 1.second
#   end
# end
#

# rule 'Dim a switch on system startup by 5 over 20 seconds' do
#   on_start
#   100.step(by: -5, to: 0) do | level |
#     run { DimmerSwitch << level }
#     delay 1.second
#   end
# end

# rule 'Log an entry if started between 3:30:04 and midnight using strings' do
#  on_start
#  run { logger.info ("Started at #{TimeOfDay.now}")}
#  between '3:30:04'..MIDNIGHT
# end

# rule 'Log an entry if started between 3:30:04 and midnight using TimeOfDay objects' do
#  on_start
#  run { logger.info ("Started at #{TimeOfDay.now}")}
#  between TimeOfDay.new(h: 3, m: 30, s: 4)..TimeOfDay.midnight
# end

# rule 'Log an entry at 11:21' do
#  every TimeOfDay.new(h: 11, m: 21)
#  run { logger.info("Rule #{name} run at #{TimeOfDay.now}") }
# end

# puts items + groups

# lowerSwitch <<  OFF
# OtherItem << ON
# Foo << 5

# open_doors = items.each
#                  .select(&:open?)
#                  .map(&:name)
#                  .join(', ')

# logger.info(open_doors)

=begin
 rule 'Log state of all doors on system startup' do
   on_start
   run do
     Doors.members.each do |door|
       case door
       when OPEN then logger.info("#{door} is Open")
       when CLOSED then logger.info("#{door} is Open")
       else logger.info("#{door} is not initialized")
       end
     end
   end
 end

 rule 'Turn off any dimmers curently on at midnight' do
   every :day
   on_start
   run do
     items.select{ |item| item.is_a? Dimmer}
          .select(&:on?)
          .each(&:off)
     end
 end

rule 'Snap Fan to preset percentages' do

  changed *CeilingFans, to: 53, for: 10.seconds
  triggered do |item|
    case item
    when 0...25
      logger.info("Snapping fan #{item} to 25")
      item << 25
    when 26...66
      logger.info("Snapping fan #{item} to 66")
      item << 66
    when 67...100
      logger.info("Snapping fan #{item} to 100")
      item << 100
    else
      logger.info("#{item} set to snapped percentage, no action take.")
    end
  end
end
=end

# puts global_variables
# puts $scriptExtension
# puts $scriptExtension.methods
# puts $FILENAME
# puts __FILE__
# puts __dir__

require 'java'
require 'pp'

# pp Java::java::lang::Thread.currentThread().getStackTrace()
pp __FILE__
pp __dir__

=begin
def notify_open_garage_door(reason)
  logger.info('Checking for open garage doors')
  open_garage_doors = GarageDoors.select(&:open?)
  logger.warn("#{open_garage_doors.length} Garage Doors are open")
  open_garage_doors.each do | door |
    notification_text = "#{reason} and #{door} is open"
    logger.warn("Sending notification #{notification_text}")
    notify('broconne@gmail.com', notification_text)
  end
end

rule 'Check Garage Doors at night' do
  every TimeOfDay.new(h: 20)
  run { notify_open_garage_door("It's 8PM") }
end

rule 'Check Garage Doors when alarm armed in night mode' do
  #changed Alarm_Mode to [10, 14]
  changed Alarm_Mode, to: 10
  changed Alarm_Mode, to: 14
  run { notify_open_garage_door("Alarm is armed") }
end
=end

# rule 'Simple' do
#  every 1.minute
#  changed VirtualSwitch, to: ON, from: OFF
#
#  run { logger.info 'Run 1' }
#  delay 5.seconds
#  run { logger.info 'Run 2' }
#
#  only_if lowerSwitch, OtherItem
#  not_if Foo
#  enabled false
# end

# rule 'Test Rule' do
#  every 1.minute
# every :minute
#  changed VirtualSwitch, to: ON, from: OFF
#  changed VirtualSwitch

#  run { logger.info 'Run 1' }
#  delay 5.seconds
#  run { logger.info 'Run 2' }

#  only_if lowerSwitch, OtherItem
#  not_if Foo
# not_if { lowerSwitch == ON }
#  enabled false
# end

# rubocop:enable Style/BlockComments
