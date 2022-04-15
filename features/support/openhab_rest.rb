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

  def self.rules
    get('/rest/rules')
  end

  def self.rule(rule:)
    rules.first { |r| rule&.name&.chomp == r.chomp }
  end

  def self.items
    get('/rest/items')
  end

  def self.set_item_state(name, state)
    put "/rest/items/#{name}/state", headers: text, body: state
  end

  def self.item_state(name)
    (get "/rest/items/#{name}/state", :headers => text, :format => :text).chomp
  end

  def self.delete_item(name)
    delete "/rest/items/#{name}"
  end

  def self.add_metadata(item:, namespace:, config:)
    put "/rest/items/#{item}/metadata/#{namespace}", headers: json, body: config
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
    post('/rest/things', headers: json, body: body.to_json)
  end

  def self.add_item(item:)
    body = item_body(item)
    item_function(body, item)
    put("/rest/items/#{item.name}", headers: json, body: body.to_json)
    item_pattern(item)
    state = item.state || 'UNDEF'
    set_item_state(item.name, state)
  end

  def self.item_body(item)
    body = {}
    body[:type] = item.type
    body[:name] = item.name
    body[:label] = item.label if item.label && item.label.strip != ''
    item_tags(body, item)
    item_groups(body, item)
    body
  end

  def self.item_pattern(item)
    return unless item.pattern

    pattern_body = {}
    pattern_body[:value] = ' '
    pattern_body[:config] = { pattern: item.pattern }
    put("/rest/items/#{item.name}/metadata/stateDescription", headers: json, body: pattern_body.to_json)
  end

  def self.item_function(body, item)
    return unless item.function

    function_body = {}
    function_body[:name] = item.function
    function_body[:params] = item.params if item.params
    body[:function] = function_body
  end

  def self.item_tags(body, item)
    body[:tags] = item.tags unless item.tags.nil? || item.tags.empty?
  end

  def self.item_groups(body, item)
    groups = [*item.groups].compact.map(&:strip).grep_v('')
    body[:groupNames] = groups unless groups.empty?
    body[:groupType] = item.group_type unless item.group_type.to_s.empty?
  end

  def self.link_item(item_name:, channel_uid:)
    body = { itemName: item_name, channelUID: channel_uid }
    escaped_channel_uid = URI.encode_www_form_component(channel_uid)
    put("/rest/links/#{item_name}/#{escaped_channel_uid}", headers: json, body: body.to_json)
  end
end
