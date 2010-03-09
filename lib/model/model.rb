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


    # -------- Methods from DeviceResultInt.DeviceResultInt -------- #

    def get_device_class_name
      rest('getDeviceClassName')
    end

  end # Model
end # Zenoss

require 'model/device'
require 'model/device_class'
require 'model/device_hw'
require 'model/operating_system'
