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
    class DeviceClass
      include Zenoss
      include Zenoss::Model

      attr_reader :organizer_name

      def initialize(devclass)
        @base_id = 'Devices'

        # This confusing little ditty lets us accept a DeviceClass in a number of ways:
        # Like, '/zport/dmd/Devices/Server/Linux'
        # or, '/Devices/Server/Linux'
        # or, '/Server/Linux'
        path = devclass.sub(/^(\/zport\/dmd\/)?(@base_id\/)?([^\/]+)\/?$/,'\2')
        @organizer_name = rest('getOrganizerName', "#{@base_id}/#{path}")
      end

      # ------------------------- Utility Methods ------------------------- #
      # These are methods that do not exist as part of the official Zenoss
      # API, but from an object model they seem to make sense to me.
      # ------------------------------------------------------------------- #

      # Add a device beneath this Device Class.  It is also typically best
      # to use the fully qualified version of the device name.
      # It returns true if the device is added, false otherwise.
      def add_device(fully_qualified_device)
        loader = ZDeviceLoader.instance
        loader.load_device(fully_qualified_device, @organizer_name)
      end



      # ----------------- REST Methods ---------------- #

      # Name of the device in Zenoss.  This method will return the first
      # match if the device_name is not fully qualified.
      def find_device_path(device_name)
        devpath = rest("findDevicePath?devicename=#{device_name}")
        return Device.new(devpath)
      end

      def get_sub_devices
        plist_to_array( rest('getSubDevices') )
      end


      private

      def rest(method, path = "#{@base_id}#{@organizer_name}")
        super("#{path}/#{method}")
      end

    end # DeviceClass
  end # Model
end # Zenoss
