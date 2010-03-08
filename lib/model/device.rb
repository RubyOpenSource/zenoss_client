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

      @@zenoss_methods = []

      zenoss_list( {:get_device_group_names => 'getDeviceGroupNames', :get_system_names => 'getSystemNames'} )
      zenoss_datetime( {:get_last_change => 'getLastChange', :get_snmp_last_collection => 'getSnmpLastCollection' } )
      zenoss_string( {:sys_uptime => 'sysUpTime', :get_hw_product_name => 'getHWProductName', :get_location_link => 'getLocationLink',
                    :get_location_name => 'getLocationName', :get_data_for_json => 'getDataForJSON', :get_manage_ip => 'getManageIp',
                    :get_performance_server_name => 'getPerformanceServerName', :get_ping_status_string => 'getPingStatusString',
                    :get_pretty_link => 'getPrettyLink', :get_priority_string => 'getPriorityString',
                    :get_production_state_string => 'getProductionStateString', :get_snmp_status_string => 'getSnmpStatusString',
                    :uptime_str => 'uptimeStr'
      } )

      zenoss_int( {:get_priority => 'getPriority'} )

      zenoss_boolean( {:monitor_device? => 'monitorDevice', :snmp_monitor_device? => 'snmpMonitorDevice' } )


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

      # Return an array of implemented Zenoss REST methods
      def zenoss_methods
        @@zenoss_methods
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

      # Return the Zenoss /Systems that this device belogs to in a string
      # separated by "sep".
      def get_system_names_string(sep=',')
        rest("getSystemNamesString?sep=#{sep}")
      end


      # -------- Methods from DeviceResultInt.DeviceResultInt -------- #
      zenoss_string( {:get_device_class_name => 'getDeviceClassName'} )


      private

      def rest(method)
        super("#{@path}/#{@device}/#{method}")
      end

    end # Device
  end # Model
end # Zenoss
