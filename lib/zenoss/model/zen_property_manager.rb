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
    module ZenPropertyManager

      # ------------------ REST Calls ------------------ #

      # @return [Array] Return an Array of zProperty Ids for this device
      def zen_property_ids
        method = 'zenPropertyIds'

        plist_to_array( rest(method) )
      end

      # @return [Hash] Return a Hash of zProperies and values
      def zen_property_items
        method = 'zenPropertyItems'

        outstr = rest(method)
        ptuples_to_hash outstr.slice(1..-2).split(/,(?=\s\()/)
      end

      # Set a zProperty
      # @param [String] propname the property to set
      # @param [String, Array, Boolean] propvalue the value to set the property to
      # @return
      def set_zen_property(propname, propvalue)
        method = 'setZenProperty'
        if(propvalue.is_a? Array)
          custom_rest("#{method}?propname=#{propname}&propvalue=[#{propvalue.join(',')}]")
        else
          if(propvalue.is_a?(TrueClass) || propvalue.is_a?(FalseClass))
            propvalue = propvalue.to_s.capitalize
          end
          custom_rest("#{method}?propname=#{propname}&propvalue=#{propvalue}")
        end
      end

    end # ZenPropertyManager
  end # Model
end # Zenoss
