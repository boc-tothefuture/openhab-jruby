# frozen_string_literal: true

require 'pp'
require 'httparty'
require 'persistent_httparty'

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
    (get "/rest/items/#{name}/state", headers: text, format: :text).chomp
  end

  def self.delete_item(name)
    delete "/rest/items/#{name}"
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

  def self.add_item(type:, name:, state: nil, label: nil, groups: nil, group_type: nil, function: nil, params: nil, pattern: nil)
    body = {}
    body[:type] = type
    body[:name] = name
    body[:label] = label if label && label.strip != ''
    groups = [*groups].compact.map(&:strip).grep_v('')
    body[:groupNames] = groups unless groups.empty?
    body[:groupType] = group_type unless group_type.to_s.empty?
    if function
      function_body = {}
      function_body[:name] = function
      function_body[:params] = params if params
      body[:function] = function_body
    end
    put("/rest/items/#{name}", headers: json, body: body.to_json)

    if pattern
      pattern_body = {}
      pattern_body[:value] = ' '
      pattern_body[:config] = { pattern: pattern }
      put("/rest/items/#{name}/metadata/stateDescription", headers: json, body: pattern_body.to_json)
    end

    state ||= 'UNDEF'
    set_item_state(name, state)
  end
end
