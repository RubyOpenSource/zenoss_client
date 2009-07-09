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
require 'lib/ZenModelBase'
require 'net/http'
class Device
	include ZenModelBase
	def initialize(device)
		@device = device
	end

	def getId()
		puts "getting DevID....."
		Net::HTTP.start(@@base_uri.host,@@base_uri.port) {|http|
			req = Net::HTTP::Get.new("#{@device}/getId")
			req.basic_auth @@user, @@pass
			response = http.request(req)
			puts response.body
		}
	end
end


