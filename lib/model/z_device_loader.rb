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
require 'singleton'
module Zenoss
  module Model
    class ZDeviceLoader
      include Model
      include Singleton

      def initialize
        @path = "DeviceLoader"
      end
      

      # Load a device into the database connecting its major relations and collecting its configuration.
      # loadDevice(self, deviceName, devicePath="/Discovered", tag="", serialNumber="", zSnmpCommunity="",
      # zSnmpPort=161, zSnmpVer=None, rackSlot=0, productionState=1000, comments="", hwManufacturer="",
      # hwProductName="", osManufacturer="", osProductName="", locationPath="", groupPaths=[], systemPaths=[],
      # performanceMonitor="localhost", discoverProto="snmp", priority=3, REQUEST=None)
      #
      # TODO: Enhance this functionality
      # Return: true if the device is added, false if it is not
      def load_device(device_name, device_path)
        method = "loadDevice?deviceName=#{device_name}&devicePath=#{device_path}"
        body = rest(method)
        (body =~ /Navigate to device/) ? true : false
      end
      
      #add a system to the database
      # addSystem(self, newSystemPath, REQUEST=None)
      def add_system(system_path)
        method = "addSystem?newSystemPath=#{system_path}"
        body = rest(method)
      end

      
      private

      def rest(method)
        super("#{@path}/#{method}")
      end



    end # ZDeviceLoader
  end # Model
end # Zenoss
