# frozen_string_literal: true

module OpenHAB
  module RSpec
    module Mocks
      class PersistenceService
        include org.openhab.core.persistence.ModifiablePersistenceService
        include Singleton

        class HistoricItem
          include org.openhab.core.persistence.HistoricItem

          attr_reader :timestamp, :state, :name

          def initialize(timestamp, state, name)
            @timestamp = timestamp
            @state = state
            @name = name
          end
        end

        attr_reader :id

        def initialize
          @id = "default"
          reset
        end

        def reset
          @data = Hash.new { |h, k| h[k] = [] }
        end

        def store(item, date = nil, state = nil)
          date = nil if date.is_a?(String) # alias overload
          state ||= item.state
          date ||= ZonedDateTime.now

          new_item = HistoricItem.new(date, state, item.name)

          item_history = @data[item.name]

          insert_index = item_history.bsearch_index do |i|
            i.timestamp.compare_to(date).positive?
          end

          return item_history << new_item unless insert_index

          return item_history[insert_index].state = state if item_history[insert_index].timestamp == date

          item_history.insert(insert_index, new_item)
        end

        def remove(filter)
          query_internal(filter) do |item_history, index|
            historic_item = item_history.delete_at(index)
            @data.delete(historic_item.name) if item_history.empty?
          end
        end

        def query(filter)
          result = []

          query_internal(filter) do |item_history, index|
            result << item_history[index]

            return result if filter.page_number.zero? && result.length == filter.page_size && filter.item_name
          end

          result.sort_by! { |hi| hi.timestamp.to_instant.to_epoch_milli } unless filter.item_name

          result = result.slice(filter.page_number * filter.page_size, filter.page_size) unless filter.page_number.zero?

          result
        end

        def get_item_info # rubocop:disable Naming/AccessorMethodName must match Java interface
          @data.map do |(n, entries)|
            [n, entries.length, entries.first.timestamp, entries.last.timestamp]
          end.to_set
        end

        def get_default_strategies # rubocop:disable Naming/AccessorMethodName must match Java interface
          [org.openhab.core.persistence.strategy.PersistenceStrategy::Globals::CHANGE]
        end

        private

        def query_internal(filter, &block)
          if filter.item_name
            return unless @data.key?(filter.item_name)

            query_item_internal(@data[filter.item_name], filter, &block)
          else
            @data.each_value do |item_history|
              query_item_internal(item_history, filter, &block)
            end
          end
        end

        def query_item_internal(item_history, filter)
          first_index = 0
          last_index = item_history.length

          if filter.begin_date
            first_index = item_history.bsearch_index do |i|
              i.timestamp.compare_to(filter.begin_date).positive?
            end
            return if first_index.nil?
          end

          if filter.end_date
            last_index = item_history.bsearch_index do |i|
              i.timestamp.compare_to(filter.end_date).positive?
            end
            return if last_index.zero?

            last_index ||= item_history.length
          end

          range = first_index...last_index

          operator = filter.operator.symbol
          operator = "==" if operator == "="

          block = lambda do |i|
            next if filter.state && !item_history[i].state.send(operator, filter.state)

            yield(item_history, i)
          end

          if filter.ordering == filter.class::Ordering::DESCENDING
            range.reverse_each(&block)
          else
            range.each(&block)
          end
        end
      end
    end
  end
end
