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
require 'uri'
module Zenoss
  module Model
    module Events
      class EventManagerBase
        include Zenoss::Model

        def initialize(manager_base)
          @manager = manager_base.sub(/^(\/zport\/dmd\/)?([^\/]+)$/,'\2')

          # Initialize common things from Model
          model_init
        end


        # ------------------ REST Calls ------------------ #

        def get_event_list(resultFields=nil, where=nil, orderby=nil, severity=nil, state=2, startdate=nil, enddate=nil, offset=0, rows=0, get_total_count=false, filter=nil, filters=nil)
          method = "getEventList?"
          method << (resultFields.nil? ? "None&" : "#{resultFields.join(',')}&")
          method << (where.nil? ? "&" : URI.encode(where,'='))
          events = []
          (parse_array(custom_rest(method, 'getEventFields'))).each do |event|
            events << Zenoss::Event::ZEvent.new(Hash[event])
          end
          events
        end

        # Parameters:
        # * evid (string) - Event ID
        # * dedupid (string) - string used to determine duplicates
        # * better (boolean) - provide even more detail than normal?
        # Returns: EventDetail object fields from the event 
        def get_event_detail(evid=nil, dedupid=nil, better=false)
        end


        private

        def rest(method)
          super("#{@manager}/#{method}")
        end

      end # EventManagerBase
    end # Events
  end # Model
end # Zenoss
