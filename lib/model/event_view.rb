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
    module EventView

      def get_event_history
        #rest('getEventHistory')
        get_event_manager('history')
      end

      def get_event_manager(table='status')
        manager = rest("getEventManager?table=#{table}")
        Model::Events::MySqlEventManager.new(manager.sub(/.* at (.*)>$/,'\1'))
      end

      # Fetches that status number for this device or component
      def get_status(statusclass=nil)
        method = 'getStatus'
        method << "?statusclass=#{statusclass}" unless statusclass.nil?

        # nil.to_i is 0 so we should be OK for nil returns
        rest(method).to_i
      end

      # Fetches the img src path for this status number.  This is usually the
      # output from the #get_status method.  If this is not working you may
      # need to apply this patch to Zenoss:
      # http://gist.github.com/328414
      def get_status_img_src(status_number)
        custom_rest("getStatusImgSrc?status=#{status_number}")
      end

      # Fetches the css class for this status number.  This is usually the
      # output from the #get_status method.  If this is not working you may
      # need to apply this patch to Zenoss:
      # http://gist.github.com/328414
      def get_status_css_class(status_number)
        custom_rest("getStatusCssClass?status=#{status_number}")
      end

    end # EventView
  end # Model
end # Zenoss
