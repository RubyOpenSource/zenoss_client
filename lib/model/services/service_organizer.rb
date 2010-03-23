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
  module Model
    class ServiceOrganizer
      include Zenoss
      include Zenoss::Model

      attr_reader :organizer_name

      def initialize(service_organizer)
        @base_id = 'Services'

        path = service_organizer.sub(/^(\/zport\/dmd\/)?(@base_id\/)?([^\/]+)\/?$/,'\2')
        @organizer_name = rest('getOrganizerName', "#{@base_id}/#{path}")
      end



      protected

      def rest(method, path = "#{@base_id}#{@organizer_name}")
        super("#{path}/#{method}")
      end

    end # ServiceOrganizer
  end # Model
end # Zenoss
