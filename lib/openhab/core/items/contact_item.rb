# frozen_string_literal: true

require_relative "generic_item"

module OpenHAB
  module Core
    module Items
      java_import org.openhab.core.library.items.ContactItem

      #
      #  A {ContactItem} can be used for sensors that return an "open" or
      # "closed" as a state.
      #
      # This is useful for doors, windows, etc.
      #
      # @!attribute [r] state
      #   @return [Types::OpenClosedType, nil]
      #
      # @example
      #   rule 'Log state of all doors on system startup' do
      #     on_start
      #     run do
      #       Doors.each do |door|
      #         case door.state
      #         when OPEN then logger.info("#{door.name} is Open")
      #         when CLOSED then logger.info("#{door.name} is Open")
      #         else logger.info("#{door.name} is not initialized")
      #         end
      #       end
      #     end
      #   end
      #
      class ContactItem < GenericItem
        # @!method open?
        #   Check if the item state == `OPEN`
        #   @return [true,false]
        #
        # @example Log open contacts
        #   Contacts.select(&:open?).each { |contact| logger.info("Contact #{contact.name} is open")}

        # @!method closed?
        #   Check if the item state == `CLOSED`
        #   @return [true,false]
        #
        # @example Log closed contacts
        #   Contacts.select(&:closed?).each { |contact| logger.info("Contact #{contact.name} is closed")}
      end
    end
  end
end
