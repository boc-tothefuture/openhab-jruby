# frozen_string_literal: true

require 'spec_helper'
require 'openhab/core/dsl/time_of_day'

module OpenHAB
  module Core
    module DSL
      module Tod
        describe TimeOfDay do
          using OpenHAB::Core::DSL::Tod::TimeOfDayRange

          describe '#initialize' do
            let(:tod) { TimeOfDay.new(h: 6, m: 30, s: 6) }

            it 'Constructs a TimeOfDay from named paramaters' do
              expect(tod.hour).to eq(6)
              expect(tod.minute).to eq(30)
              expect(tod.second).to eq(6)
            end

            it 'Should be midnight if no arguments are passed' do
              expect(TimeOfDay.new).to eq(TimeOfDay.parse(MIDNIGHT))
            end

            it 'Midnight should be the start of the day' do
              midnight = TimeOfDay.MIDNIGHT
              expect(midnight.hour).to eq(0)
              expect(midnight.minute).to eq(0)
              expect(midnight.second).to eq(0)
            end

            it 'Noon should be 12:00:00' do
              noon = TimeOfDay.NOON
              expect(noon.hour).to eq(12)
              expect(noon.minute).to eq(0)
              expect(noon.second).to eq(0)
            end
          end

          describe '.now' do
            it 'Should return a Time Of Day object' do
              tod = TimeOfDay.now
              expect(tod).not_to be_nil
            end
          end

          describe '.parse' do
            it 'Should create a time of day string from "06:30:45"' do
              tod = TimeOfDay.parse('06:30:45')
              expect(tod.hour).to eq(6)
              expect(tod.minute).to eq(30)
              expect(tod.second).to eq(45)
            end

            it 'Should create a time of day string from "18:07"' do
              tod = TimeOfDay.parse('18:07')
              expect(tod.hour).to eq(18)
              expect(tod.minute).to eq(0o7)
              expect(tod.second).to eq(0)
            end

            it 'Should create a time of day string from "6:07"' do
              tod = TimeOfDay.parse('6:07')
              expect(tod.hour).to eq(6)
              expect(tod.minute).to eq(7)
              expect(tod.second).to eq(0)
            end

            it 'Should create a time of day string from "15"' do
              tod = TimeOfDay.parse('15')
              expect(tod.hour).to eq(15)
              expect(tod.minute).to eq(0)
              expect(tod.second).to eq(0)
            end

            it 'Should create a time of day string from "6"' do
              tod = TimeOfDay.parse('6')
              expect(tod.hour).to eq(6)
              expect(tod.minute).to eq(0)
              expect(tod.second).to eq(0)
            end
          end

          describe '.to_s' do
            it 'Returns a TimeOfDay in the format of HH:MM:SS' do
              tod = TimeOfDay.new(h: 6, m: 30, s: 6)
              expect(tod.to_s).to eq('06:30:06')
            end
          end

          describe '.cover?' do
            it 'Does not raise an exception when called with valid values' do
              expect { OpenHAB::Core::DSL::Tod::TimeOfDayRange::ALL_DAY.cover?(TimeOfDay.now) }.not_to raise_error
              expect(OpenHAB::Core::DSL::Tod::TimeOfDayRange::ALL_DAY.cover?(TimeOfDay.now)).to be true
            end
          end

          context "Range isn't constructed from TimeOfDay Objects" do
            let(:range) { (1..20) }

            cover_cases = {
              0 => false,
              10 => true,
              20 => true,
              21 => false
            }

            cover_cases.each do |input, result|
              it "should return #{result} for cover? #{input}" do
                expect(range.cover?(input)).to be result
              end
            end

            include_cases = {
              0 => false,
              1 => true,
              10 => true,
              20 => true,
              21 => false
            }

            include_cases.each do |input, result|
              it "should return #{result} for include? #{input}" do
                expect(range.include?(input)).to be result
              end
            end
          end

          context 'Range excludes ending' do
            let(:range) { '22:01'...'6:30:25' }

            it 'Should return true one second before range ends' do
              expect(range.cover?('6:30:24')).to be true
            end

            it 'Should return false when range ends' do
              expect(range.cover?('6:30:25')).to be false
            end
          end

          context 'Range created with strings' do
            let(:range) { '22:01'..'6:30:25' }

            tests = {
              TimeOfDay.new(h: 19) => false,
              TimeOfDay.new(h: 23, m: 30, s: 30) => true,
              TimeOfDay.new(h: 2, m: 0, s: 30) => true,
              TimeOfDay.new(h: 6, m: 30, s: 25) => true,
              TimeOfDay.new(h: 7) => false
            }

            tests.each do |input, result|
              it "should return #{result} for cover? #{input}" do
                expect(range.cover?(input)).to be result
              end

              it "should return #{result} for include? #{input}" do
                expect(range.include?(input)).to be result
              end
            end
          end

          context 'Time of Day range does not pass midnight' do
            let(:range) { TimeOfDay.new(h: 6)..TimeOfDay.new(h: 22) }

            tests = {
              TimeOfDay.new(h: 5) => false,
              TimeOfDay.new(h: 9, s: 30) => true,
              TimeOfDay.new(h: 23, m: 20, s: 0) => false
            }

            tests.each do |input, result|
              it "should return #{result} for cover? #{input}" do
                expect(range.cover?(input)).to be result
              end

              it "should return #{result} for include? #{input}" do
                expect(range.include?(input)).to be result
              end
            end
          end

          context 'Time of Day range passes midnight' do
            let(:range) { TimeOfDay.new(h: 22)..TimeOfDay.new(h: 6) }

            tests = {
              TimeOfDay.new(h: 19) => false,
              TimeOfDay.new(h: 23, m: 30, s: 30) => true,
              TimeOfDay.new(h: 2, m: 0, s: 30) => true,
              TimeOfDay.new(h: 7) => false
            }

            tests.each do |input, result|
              it "should return #{result} for cover? #{input}" do
                expect(range.cover?(input)).to be result
              end

              it "should return #{result} for include? #{input}" do
                expect(range.include?(input)).to be result
              end
            end
          end
        end
      end
    end
  end
end
