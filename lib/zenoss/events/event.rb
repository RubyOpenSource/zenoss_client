# coding: utf-8
#############################################################################
# Copyright © 2010 Dan Wanek <dwanek@nd.gov>
#
#
# This file is part of zenoss_client.
# 
# zenoss_client is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or (at
# your option) any later version.
# 
# zenoss_client is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.
# 
# You should have received a copy of the GNU General Public License along
# with zenoss_client.  If not, see <http://www.gnu.org/licenses/>.
#############################################################################

module Zenoss
  module Events
    class Event < OpenStruct

      # Initialize this object from a Hash returned via the JSON api
      # @param[Zenoss] zenoss the current instance we are connecting with
      # @param[Hash] zhash a hash of values used to create this Event instance
      def initialize(zenoss,zhash)
        @zenoss = zenoss
        super zhash
        parse_time_format
      end

      # Check to see if firstTime is set and not set to false
      # @return[Time, nil] self.firstTime
      def first_time?
        if self.firstTime && self.firstTime != false
          self.firstTime
        end
      end

      # Check to see if lastTime is set and not set to false
      # @return[Time, nil] self.lastTime
      def last_time?
        if self.lastTime && self.lastTime != false
          self.lastTime
        end
      end

      # Parses the firstTime value
      # @return[Time] self.firstTime
      def parse_first_time
        if self.firstTime.is_a?(String)
          self.firstTime = Time.parse(self.firstTime)
        else
          self.firstTime = Time.at(self.firstTime)
        end
      end

      # Parses the lastTime value
      # @return[Time] self.lastTime
      def parse_last_time
        if self.lastTime.is_a?(String)
          self.lastTime = Time.parse(self.lastTime)
        else
          self.lastTime = Time.at(self.lastTime)
        end
      end

      # Parse time format from zenoss
      # Zenoss version 4 emits the time format to be a string
      # Zenoss version 6 emits the time to be a float
      # @return[Time] self.firstTime, self.lastTime the time from zenoss
      def parse_time_format
        if first_time?
          parse_first_time
        end

        if last_time?
          parse_last_time
        end
      end

      def detail(history = false)
        data = {
          :evid => self.evid,
          :history => history,
        }
        resp = @zenoss.json_request('EventsRouter', 'detail', [data])
        resp['event'].first.each_pair do |k,v|
          self.new_ostruct_member(k)
          @table[k.to_sym] = v
        end
      end

      def acknowledge
      end

    end # Event
  end # Events
end # Zenoss
