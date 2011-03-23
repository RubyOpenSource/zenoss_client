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
  module JSONAPI
    module EventsRouter

      def get_events(device=nil, component=nil, event_class=nil, limit=100)
        data = {
          :start  => 0,
          :limit  => 100,
          :dir    => 'DESC',
          :sort   => 'severity',
          :params => { :severity => [5,4,3,2,1], :eventState => [0,1]},
        }
        data[:params][:device] = device if device
        data[:params][:component] = component if component
        data[:params][:eventClass] = event_class if event_class

        resp = json_request('EventsRouter', 'query', [data])

        events = []
        resp['events'].each do |ev|
          events << Events::ZEvent.new(self, ev)
        end
        events
      end

    end # EventsRouter
  end # JSON
end # Zenoss
