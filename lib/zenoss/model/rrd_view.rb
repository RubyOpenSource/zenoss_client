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
        (plist_to_array( custom_rest('getRRDDataPoints').chomp )).map do |dstr|
          dp = dstr.sub(/^<([\w]+)\s+at\s+(.*)>$/,'\2')
          RRDDataPoint.new(@zenoss,dp)
        end
      end

      # Get key/value pairs of RRD Values for the passed data source names.
      #
      # @param [Array <String>] dsnames data source names from RRDDataPoint#name
      # @return [Hash] key/value pairs of data source name and data source values
      def get_rrd_values(dsnames)
        pdict_to_hash(custom_rest("getRRDValues?dsnames=[#{dsnames.join(',')}]"))
      end

      # Get all of the data point falues between a certain time period
      # @param [String] dpname the name of the data point to retrieve values for
      # @param [String] cf the RRD consolidation function to use
      #   AVERAGE,MIN,MAX,LAST
      # @param [Fixnum] resolution the RRD resolution to use. This is the interval
      #   between values. It defaults to 300 seconds (5 minutes).
      # @param [DateTime] start the time to begin fetching values from
      # @param [DataTime] end the time to stop fetching values at. It defaults to now.
      # @example An example of the actuall HTTP call
      #   http://myhost:8080/zport/dmd/Devices/path/callZenossMethod?methodName=fetchRRDValue&args=[my_dpoint===AVERAGE===300===1300761000===1300776100]
      def fetch_rrd_value(dpname,vstart,vend=DateTime.now,cf='AVERAGE',resolution=300)
        method =  "fetchRRDValue?dpname=#{dpname}"
        method << "&cf=#{cf}&resolution=#{resolution}"
        method << "&start=#{vstart.strftime('%s')}"
        method << "&end=#{vend.strftime('%s')}"
        custom_rest(method)
        parse_rrd_fetch(custom_rest(method))
      end

      #private


      # Parse the string returned by the REST call fetchRRDValue.
      def parse_rrd_fetch(vstr)
        vstr = vstr.chomp
        vstr = vstr.slice 1, (vstr.length - 2)
        parts = vstr.match(/^\(([^\)]+)\),\s*\(([^\)]+)\),\s*\[([^\]]+)\]/)

        # Get the first part of the return, start, end, resolution
        retparms = Hash[[:start,:end,:resolution].zip( parts[1].split(/\s*,\s*/).map {|v| v.to_i} )]
        # Get the datasource name. This will almost always be 'ds0'
        retparms[:rrdds] = parts[2].gsub(/['"]/,'').split(/,/).first
        # Get the values
        retparms[:rrdvalues] = plist_to_array(parts[3]).map do |v|
          atom = v.gsub(/(\(|\))/,'').split(/\s*,\s*/)[0]
          case atom
          when /\d\.\d/
            atom.to_f
          when /^\d$/
            atom.to_i
          when /None/
            nil
          end
        end
        retparms
      end

    end # RRDView
  end # Model
end # Zenoss

# Load the RRD related files
require 'zenoss/model/rrd/rrd_data_point'
