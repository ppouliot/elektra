module Core
  module ServiceLayer
    module FogDriver
      module ClientHelper
        def auth_params
          result = {
            openstack_auth_token: @token,
            openstack_auth_url: @auth_url,
            openstack_region: @region
          }

          result[:openstack_domain_id]  = @domain_id if @domain_id
          result[:openstack_project_id] = @project_id if @project_id

          result[:connection_options] = {
            # remove this shit after the certificates for endpoints are configured correctly!
            ssl_verify_peer:  false,
            debug_request:    Rails.configuration.debug_api_calls,
            debug_response:   Rails.configuration.debug_api_calls,
            debug: Rails.configuration.debug_api_calls
          }

          result
        end
      end
    end
  end
end
