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

# This file contains helper modules for minor classes that have to deal
# with Devices and DeviceClasses.

module Zenoss
  module Model

    module DeviceResultInt

      # Return the path of the device_class; everything after '/zport/dmd/Devices'
      def get_device_class_name
        @cache_vars[:device_class_name] ||= rest('getDeviceClassName')
      end

      # Return the path of the device_class; everything after '/zport/dmd/Devices'
      def get_device_class_path
        get_device_class_name
      end

      # Return the DeviceClass object of this object
      def device_class
        @cache_vars[:device_class] ||= DeviceClass.new(get_device_class_name)
      end
    end # DeviceResultInt

  end # Model
end # Zenoss


# Load the main Device related files
require 'zenoss/model/devices/device_class'
require 'zenoss/model/devices/device'
require 'zenoss/model/devices/device_hw'
require 'zenoss/model/devices/operating_system'
