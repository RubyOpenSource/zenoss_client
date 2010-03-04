#############################################################################
# Copyright © 2010 Dan Wanek <dwanek@nd.gov>
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

module Zenoss

  # Set the Base URI of the Zenoss server
  def Zenoss.uri(uri)
    const_set(:BASE_URI, ( uri.kind_of?(URI) ?  uri : URI.parse(uri)))
  end

  def Zenoss.set_auth(user, pass)
    const_set(:USER, user)
    const_set(:PASS, pass)
  end


  protected

  # REST helper functions
  def rest(req_path)
    Net::HTTP.start(Zenoss::BASE_URI.host,Zenoss::BASE_URI.port) {|http|
      req = Net::HTTP::Get.new(req_path)
      req.basic_auth Zenoss::USER, Zenoss::USER if Zenoss::USER
      response = http.request(req)
      return(response.body)
    }
  end

end # Zenoss

require 'model/model'
