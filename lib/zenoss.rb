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
require 'rubygems'
require 'date'
require 'tzinfo'
require 'uri'

module Zenoss

  # Set the Base URI of the Zenoss server
  def Zenoss.uri(uri)
    if(uri.kind_of?(URI))
      uri.path << '/' unless(uri.path.index /\/$/)
      const_set(:BASE_URI, uri)
    else
      uri << '/' unless(uri.index /\/$/)
      const_set(:BASE_URI, URI.parse(uri))
    end
  end

  def Zenoss.set_auth(user, pass)
    const_set(:USER, user)
    const_set(:PASS, pass)
    true
  end

  # Return the base DeviceClass /zport/dmd/Devices
  def Zenoss.devices
    Model::DeviceClass.new('/zport/dmd/Devices')
  end


  protected

  # Prepend the appropriate path and call the REST method on the URL set with Zenoss#uri
  def rest(req_path)
    Net::HTTP.start(Zenoss::BASE_URI.host,Zenoss::BASE_URI.port) {|http|
      req = Net::HTTP::Get.new("#{BASE_URI.path}#{req_path}")
      req.basic_auth USER, PASS if USER
      response = http.request(req)
      return(response.body)
    }
  end

  # Some of the REST methods return Strings that are formated like a Python list.
  # This method turns that String into a Ruby Array.
  def plist_to_array(list)
    (list.gsub /[\[\]]/,'').split /,\s+/
  end

  # Converts a String in Python's DateTime format to Ruby's DateTime format
  def pdatetime_to_datetime(pdt)
    pdt = pdt.split(/\s+/)
    tz = TZInfo::Timezone.get(pdt.last)
    DateTime.strptime("#{pdt[0]} #{pdt[1]} #{tz.current_period.abbreviation.to_s}", '%Y/%m/%d %H:%M:%S.%N %Z')
  end


end # Zenoss

require 'model/model'