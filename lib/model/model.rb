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
require 'uri'
require 'net/http'

module Zenoss
  module Model
    include Zenoss

    # Common initialization for all Model components
    def model_init

      # A place to maintain cached vars to prevent unnecessary REST calls
      @cache_vars = {}
    end

    # -------- Methods from DeviceResultInt.DeviceResultInt -------- #

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


    private

    # Reset the cache variables so the REST calls return the appropriate
    # values after a change has taken place.
    def reset_cache_vars
      @cache_vars.each_key do |key|
        @cache_vars[key] = nil
      end
    end

  end # Model
end # Zenoss

# Modules
require 'model/event_view'

# Device Related
require 'model/devices/device_class'
require 'model/devices/device'
require 'model/devices/device_hw'
require 'model/devices/operating_system'

# Service Related
require 'model/services/service_organizer'
require 'model/services/service_class'
require 'model/services/service'
require 'model/services/ip_service'
require 'model/services/win_service'
