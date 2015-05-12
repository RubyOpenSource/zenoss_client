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

      # Query events for the given parameters.
      # @param [String] uid the uid to query events for. If this isn't specified
      #   the query may take a very long time
      # @param [Hash] opts misc options to limit/filter events
      # @option opts [Fixnum] :limit the Max index of events to retrieve
      # @option opts [Fixnum] :start the Min index of events to retrieve
      # @option opts [String] :sort Key on which to sort the return results (default: 'lastTime')
      # @option opts [String] :dir Sort order; can be either 'ASC' or 'DESC'
      # @option opts [Hash] :params Key-value pair of filters for this search. (default: None)
      # @option opts [Boolean<true>] :history True to search the event history
      #   table instead of active events (default: False)
      # @option opts [Array<Hash>] :criteria A list of key-value pairs to to build query's
      #   where clause (default: None)
      # @option opts [String] :device limit events to a specific device. This only makes sense
      #   if the uid being passed is not a device.
      # @option opts [String] :component limit events to a specific component
      # @option opts [String] :event_class limit events to a specific eventClass
      def query_events(uid=nil, opts = {})
        defaults = {
          :limit    => 100,
          :start    => 0,
          :sort     => 'lastTime',
          :dir      => 'DESC',
          :history  => false,
        }
        opts = defaults.merge(opts)

        resp = self.ev_query(uid, opts)

        events = []
        resp['events'].each do |ev|
          events << Events::ZEvent.new(self, ev)
        end
        events
      end


      # @param [String] uid the uid to query events for. If this isn't specified
      #   the query may take a very long time
      # @param [Hash] opts misc options to limit/filter events
      # @see #query_events
      def ev_query(uid, opts)
        data = {
          :limit    => opts[:limit],
          :start    => opts[:start],
          :sort     => opts[:sort],
          :dir      => opts[:dir],
        }
        data[:uid] = uid unless uid.nil?
        data[:params] = opts[:params] if opts.has_key?(:params)
        data[:criteria] = opts[:criteria] if opts.has_key?(:criteria)

        json_request('EventsRouter', 'query', [data])
      end

    end # EventsRouter
  end # JSONAPI
end # Zenoss
