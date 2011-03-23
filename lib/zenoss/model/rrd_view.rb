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
    module RRDView
      include Zenoss::Model

      # @return [Array] of datapoints
      def get_rrd_data_points
        (plist_to_array( custom_rest('getRRDDataPoints') )).map do |dstr|
          dp = dstr.sub(/^<([\w]+)\s+at\s+(.*)>$/,'\2')
          RRDDataPoint.new(dp)
        end
      end

      # Get key/value pairs of RRD Values for the passed data source names.
      #
      # @param [Array <String>] dsnames data source names from RRDDataPoint#name
      # @return [Hash] key/value pairs of data source name and data source values
      def get_rrd_values(dsnames)
        pdict_to_hash(custom_rest("getRRDValues?dsnames=[#{dsnames.join(',')}]"))
      end

    end # RRDView
  end # Model
end # Zenoss

# Load the RRD related files
require 'model/rrd/rrd_data_point'
