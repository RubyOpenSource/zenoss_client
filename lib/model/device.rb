#############################################################################
# Copyright © 2009 Dan Wanek <dwanek@nd.gov>
#
#
# This file is part of Zenoss-RubyREST.
# 
# Zenoss-RubyREST is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or (at
# your option) any later version.
# 
# Zenoss-RubyREST is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.
# 
# You should have received a copy of the GNU General Public License along
# with Zenoss-RubyREST.  If not, see <http://www.gnu.org/licenses/>.
#############################################################################
module Zenoss
  module Model
    class Device
      include Zenoss
      include Zenoss::Model


      def initialize(device_path)
        device_path.sub(/^\/zport\/dmd\/(.*)\/([^\/]+)$/) do |m|
          @path = $1
          @device = $2
        end
      end

      # Instead of calling the /getId REST method, this method simply returns
      # the @device value since it is the same anyway.
      def get_id()
        @device
      end

      def sys_uptime
        rest("sysUpTime")
      end

      # Return list of monitored DeviceComponents on this device
      def get_monitored_components(collector=nil, type=nil)
        method = "getMonitoredComponents"
        method << '?' unless(collector.nil? && type.nil?)
        method << "collector=#{collector}" unless collector.nil?
        method << "type=#{type}" unless type.nil?
        components = rest(method)

        # Turn the return string into an array of components
        (components.gsub /[\[\]]/,'').split /,\s+/
      end
      
      # Return list of all DeviceComponents on this device
      def get_device_components(monitored=nil, collector=nil, type=nil)
        method = "getDeviceComponents"
        method << '?' unless(monitored.nil? && collector.nil? && type.nil?)
        method << "monitored=#{monitored}" unless monitored.nil?
        method << "collector=#{collector}" unless collector.nil?
        method << "type=#{type}" unless type.nil?
        components = rest(method)

        plist_to_array(components)
      end

      def get_hw_product_name
        rest('getHWProductName')
      end

      def get_system_names
        plist_to_array( rest('getSystemNames') )
      end

      def get_device_group_names
        plist_to_array( rest('getDeviceGroupNames') )
      end

      def get_last_change
        pdatetime_to_datetime( rest('getLastChange') )
      end

      def get_manage_ip
        rest('getManageIp')
      end

      def get_snmp_last_collection
        pdatetime_to_datetime( rest('getSnmpLastCollection') )
      end

      protected

      def rest(method)
        super("#{@path}/#{@device}/#{method}")
      end

    end # Device
  end # Model
end # Zenoss
