module Openstack
  class IdentityService < OpenstackServiceProvider::FogProvider
    def driver(auth_params)
      # TODO: this line of code authenticates user and creates a new token in keystone.
      # this is not necessary because the user already exists in session and has a valid token.
      # It should be possible to create a fog instance without "new" authentication. It can use the token from session!
      Fog::IdentityV3::OpenStack.new(auth_params)
    end

    # returns domains which user has access to
    def user_domains(options={per_page: 30, page: 1})
      @driver.domains.auth_domains.all(options)
    end

    def domains(options={})
      @driver.domains.all(options)
    end

    # returns domain which user has access to
    def user_domain(domain_id)
      @driver.domains.auth_domains.find_by_id(domain_id)
    end

    # returns domain projects which user has access to
    def user_domain_projects(domain_id,options={per_page: 30, page: 1})
      @driver.projects.auth_projects.select {|project| project.domain_id==domain_id}
    end

    # returns project which user has access to
    def user_project(project_id)
      @driver.projects.auth_projects.find_by_id(project_id)
    end

    # returns all domain projects
    def domain_projects
      api_connection.projects.all(domain_id: domain_id)
    end

    # returns all roles (may filter by name)
    def roles(options = {})
      @driver.roles.all(options)
    end

    # Project CRUD

    # parameters: name, domain_id, enabled (true|false, defaults: true)
    def create_project(options = {})
      @driver.projects.create(options)
    end

    protected
    # admin connection to identity
    def api_connection
      @api_connection ||= MonsoonOpenstackAuth.api_client(@region).connection_driver.connection
    end

  end
end
