# frozen_string_literal: true

require 'pp'
require 'httparty'
require 'persistent_httparty'

#
# Rest interface for OpenHAB
#
class Rest
  include HTTParty
  persistent_connection_adapter

  format :json
  base_uri 'http://localhost:8080'
  basic_auth 'foo', 'foo'

  # rubocop:disable Metrics
  def self.openhab_retry(retries = 5)
    tries = 0

    while tries < retries
      begin
        response = yield
        return response if response.success?

        next unless tries < retries

        puts "Error communicating with openhab - try: #{tries} - #{response.inspect}"
        sleep 5
        tries += 1
      rescue StandardError => e
        puts "Error communicating with openhab - try: #{tries} - #{e}"
        sleep 5
        tries += 1
      end
    end
    raise "Unable to communicate wtih openhab #{response.inspect}"
  end
  # rubocop:enable Metrics

  def self.rules
    openhab_retry { get('/rest/rules') }
  end

  def self.rule(rule:)
    rules.first { |r| rule&.name&.chomp == r.chomp }
  end

  def self.items
    openhab_retry { get('/rest/items') }
  end

  def self.set_item_state(name, state)
    openhab_retry { put "/rest/items/#{name}/state", headers: text, body: state }
  end

  def self.item_state(name)
    openhab_retry { get "/rest/items/#{name}/state", :headers => text, :format => :text }.chomp
  end

  def self.delete_item(name)
    openhab_retry { delete "/rest/items/#{name}" }
  end

  def self.add_metadata(item:, namespace:, config:)
    openhab_retry { put "/rest/items/#{item}/metadata/#{namespace}", headers: json, body: config }
  end

  def self.delete_rule(uid)
    delete "/rest/rules/#{uid}"
  end

  def self.json
    { 'Content-Type' => 'application/json' }
  end

  def self.text
    { 'Content-Type' => 'text/plain' }
  end

  def self.add_thing(id:, uid:, thing_type_uid:, label:, config: nil)
    body = {}
    body['ID'] = id
    body['UID'] = uid
    body['thingTypeUID'] = thing_type_uid
    body[:channels] = []
    body[:label] = label
    body[:configuration] = config if config
    openhab_retry { post('/rest/things', headers: json, body: body.to_json) }
  end

  def self.add_item(item:)
    body = item_body(item)
    item_function(body, item)
    openhab_retry { put("/rest/items/#{item.name}", headers: json, body: body.to_json) }
    item_pattern(item)
    set_item_state(item.name, item.state) if item.state
  end

  def self.item_body(item)
    body = {}
    body[:type] = item.type
    body[:name] = item.name
    body[:label] = item.label if item.label && item.label.strip != ''
    item_groups(body, item)
    body
  end

  def self.item_pattern(item)
    return unless item.pattern

    pattern_body = {}
    pattern_body[:value] = ' '
    pattern_body[:config] = { pattern: item.pattern }
    openhab_retry do
      put("/rest/items/#{item.name}/metadata/stateDescription", headers: json, body: pattern_body.to_json)
    end
  end

  def self.item_function(body, item)
    return unless item.function

    function_body = {}
    function_body[:name] = item.function
    function_body[:params] = item.params if item.params
    body[:function] = function_body
  end

  def self.item_groups(body, item)
    groups = [*item.groups].compact.map(&:strip).grep_v('')
    body[:groupNames] = groups unless groups.empty?
    body[:groupType] = item.group_type unless item.group_type.to_s.empty?
  end
end
