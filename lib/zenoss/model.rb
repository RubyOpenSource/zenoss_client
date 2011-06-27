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

require 'zenoss/model/event_view'
require 'zenoss/model/rrd_view'

# Methods related to zProperties
require 'zenoss/model/zen_property_manager'

# Device Loader interface.  You can use it directly or use the
# utility methods in DeviceClass to create devices beneath
# that class
require 'zenoss/model/z_device_loader'

# Device Related ( /zport/dmd/Devices )
require 'zenoss/model/devices'

# Service Related ( /zport/dmd/Services )
require 'zenoss/model/services'

# Systems Related ( /zport/dmd/Systems )
require 'zenoss/model/systems'
