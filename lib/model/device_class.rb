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
    class DeviceClass
      include Zenoss
      include Zenoss::Model

      def initialize(devclass)
        @devclass = devclass.sub(/^(\/zport\/dmd\/)?([^\/]+)\/?$/,'\2')
      end

      # Name of the device in Zenoss.  This method will return the first
      # match if the device_name is not fully qualified.
      def find_device_path(device_name)
        devpath = rest("findDevicePath?devicename=#{device_name}")
        return Device.new(devpath)
      end


      protected

      def rest(method)
        super("#{@devclass}/#{method}")
      end

    end # DeviceClass
  end # Model
end # Zenoss
