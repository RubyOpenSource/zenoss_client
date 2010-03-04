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

      # Name of the device in Zenoss.  This method will return the first
      # match if the device_name is not fully qualified.
      def self.find_device(device_name)
        devpath = Zenoss.rest("Devices/findDev?name=#{device_name}")
        return Device.new(devpath)
      end


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

    end # Device
  end # Model
end # Zenoss
