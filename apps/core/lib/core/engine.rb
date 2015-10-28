module Core
  class Engine < ::Rails::Engine
    isolate_namespace Core
    
    initializer 'core.append_migrations' do |app|
      unless app.root.to_s == root.to_s
        config.paths["db/migrate"].expanded.each do |path|
          app.config.paths["db/migrate"].push(path)
        end
      end
    end
    
    # initializer 'core.asset_precompile_paths' do |app|
    #   app.config.assets.precompile += ["core/manifests/*"]
    # end
    
    initializer 'core.high_voltage' do |app|
      HighVoltage.configure do |config|
        config.routes = false
        config.content_path = 'core/pages/'
      end
    end

    initializer 'core.monsoon_openstack_auth' do |app|
      MonsoonOpenstackAuth.configure do |auth|
        # connection driver, default MonsoonOpenstackAuth::Driver::Default (Fog)
        # auth.connection_driver = DriverClass

        auth.connection_driver.api_endpoint = if ENV['AUTHORITY_SERVICE_HOST'] && ENV['AUTHORITY_SERVICE_PORT']
                                                  proto = ENV['AUTHORITY_SERVICE_PROTO'] || 'http'
                                                  host  = ENV['AUTHORITY_SERVICE_HOST']
                                                  port  = ENV['AUTHORITY_SERVICE_PORT']
                                                  "#{proto}://#{host}:#{port}/v3/auth/tokens"
                                                else
                                                  ENV['MONSOON_OPENSTACK_AUTH_API_ENDPOINT']
                                                end
        auth.connection_driver.api_userid   = ENV['MONSOON_OPENSTACK_AUTH_API_USERID']
        auth.connection_driver.api_domain   = ENV['MONSOON_OPENSTACK_AUTH_API_DOMAIN']
        auth.connection_driver.api_password = ENV['MONSOON_OPENSTACK_AUTH_API_PASSWORD']
        auth.connection_driver.ssl_verify_peer = false

        # optional, default=true
        auth.token_auth_allowed = true
        # optional, default=true
        auth.basic_auth_allowed = true
        # optional, default=true
        auth.sso_auth_allowed   = true
        # optional, default=true
        auth.form_auth_allowed  = true

        # optional, default=false
        auth.access_key_auth_allowed = false

        auth.default_region = ENV['MONSOON_DASHBOARD_REGION'] || 'europe'

        # optional, default=sap_default
        auth.default_domain_name = 'sap_default'

        # optional, default= last url before redirected to form
        auth.login_redirect_url = -> referrer_url, current_user { after_login_url(referrer_url, current_user)}

        # authorization policy file
        auth.authorization.policy_file_path = "config/policy.json"
        auth.authorization.context = "identity"

        #auth.authorization.trace_enabled = true
        auth.authorization.reload_policy = false
        auth.authorization.trace_enabled = false

        auth.authorization.controller_action_map = {
          :index   => 'list',
          :show    => 'get',
          :destroy => 'delete'
        }

        # optional, default=false
        auth.debug=true
      end
    end
    
    def after_login_url(referrer_url, current_user)
      redirect_to_sandbox = if referrer_url
        path = URI(referrer_url).path rescue nil
        path.nil? ? true : path.count('/') < 3
      else
        true
      end

      sandbox_url = if (redirect_to_sandbox and current_user.project_id)
        "/#{current_user.project_domain_id}/#{current_user.project_id}/projects"
      else
        nil
      end
      domain_url = "/#{current_user.domain_id}" if current_user.domain_id

      sandbox_url || referrer_url || domain_url || "/"

    rescue
      referrer_url || "/"
    end
  end
end