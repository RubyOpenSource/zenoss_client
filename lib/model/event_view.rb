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
    module EventView

      def get_event_history
        rest('getEventHistory')
      end

      def get_status(statusclass=nil)
        method = 'getStatus'
        method << "?statusclass=#{statusclass}" unless statusclass.nil?

        # nil.to_i is 0 so we should be OK for nil returns
        rest(method).to_i
      end

      def get_status_img_src(status_number)
        rest("getStatusImgSrc?status=#{status_number}")
      end

      def get_status_css_class(status_number)
        rest("getStatusCssClass?status=#{status_number}")
      end

    end # EventView
  end # Model
end # Zenoss
