# frozen_string_literal: true

RSpec.describe OpenHAB::Core::Items::Persistence do
  it "supports various persistence methods" do
    items.build { number_item "Number1", state: 10 }
    Number1.persist

    expect do
      %i[
        average_since
        changed_since?
        delta_since
        deviation_since
        evolution_rate
        historic_state
        maximum_since
        minimum_since
        sum_since
        updated_since?
        variance_since
      ].each do |method|
        Number1.__send__(method, 1.minute.ago)
      end

      %i[
        average_between
        changed_between?
        delta_between
        deviation_between
        maximum_between
        minimum_between
        sum_between
        updated_between?
        variance_between
      ].each do |method|
        Number1.__send__(method, 2.minutes.ago, 1.minute.ago)
      end
    end.not_to raise_error
  end

  it "handles persistence data with units of measurement" do
    items.build { number_item "Number_Power", dimension: "Power", format: "%.1f kW", state: 3 }
    Number_Power.persist
    expect(Number_Power.maximum_since(10.seconds.ago)).to eql(3 | "kW")
  end

  it "handles persistence data on plain number item" do
    items.build { number_item "Number1", state: 3 }
    Number1.persist
    expect(Number1.maximum_since(10.seconds.ago)).to eq 3
  end

  it "HistoricState directly returns a timestamp" do
    Timecop.freeze
    items.build { number_item "Number1", state: 3 }
    Number1.persist
    max = Number1.maximum_since(10.seconds.ago)
    expect(max.timestamp.to_i).to eq Time.now.to_i
    expect(max).to eq max.state
  end
end
