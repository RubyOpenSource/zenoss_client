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
    class RRDDataPoint
      include Zenoss
      include Zenoss::Model

      def initialize(datapoint_path)
        @path = datapoint_path

        # Initialize common things from Model
        model_init
      end

      # ------------------------- Utility Methods ------------------------- #
      # These are methods that do not exist as part of the official Zenoss
      # API, but from an object model they seem to make sense to me.
      # ------------------------------------------------------------------- #



      # --------------------------- REST Methods -------------------------- #

      # @return [String] Name of the data source
      def name
        @cache_vars[:name] ||= rest('name')
      end


      private

      def rest(method, path = "#{@path}")
        super("#{path}/#{method}")
      end

    end # DeviceClass
  end # Model
end # Zenoss
