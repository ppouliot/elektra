# This class guarantees that the user is logged in and his token is rescoped.
# All subclasses which require a logged in user should inherit from this class.
class DashboardController < ::ScopeController
  # authenticate user -> current_user is available
  authentication_required domain: -> c { c.instance_variable_get("@scoped_domain_id") },
                          domain_name: -> c { c.instance_variable_get("@scoped_domain_name") },
                          project: -> c { c.instance_variable_get('@scoped_project_id') },
                          rescope: false # do not rescope after authentication


                          
  # check if user has accepted terms of use. Otherwise it is a new, unboarded user.
  before_filter :check_terms_of_use  
  # rescope token
  before_filter :authentication_rescope_token
  before_filter :load_user_projects
  before_filter :set_mailer_host
  
  # token is expired or was revoked -> redirect to login page
  rescue_from "Identity::InvalidToken" do
    redirect_to monsoon_openstack_auth.login_path(domain_name:@scoped_domain_name)
  end

  DOMAIN_ACCESS_INQUIRY = 'domain-access'

  def check_terms_of_use
    if new_user?
      redirect_to "/#{@scoped_domain_fid}/onboarding" and return
    end
  end

  protected

  def load_user_projects
    # get all projects for user (this might be expensive, might need caching, ajaxifying, ...)
    @user_domain_projects ||= services.identity.auth_projects(@scoped_domain_id).sort_by { |project| project.name }

    # load active project
    if @scoped_project_id
      # @active_project ||= @user_domain_projects.find { |project| project.id == @scoped_project_id }
      @active_project = services.identity.find_project(@scoped_project_id, [:subtree_as_ids, :parents_as_ids])
    end
  end


  def authorization_forbidden exception
    @exception = exception
    respond_to do |format|
      format.html { render "dashboard/forbidden", :status => :forbidden }
      format.js { render "dashboard/forbidden.js" }
    end
  end

  def new_user?
    # Consider that every plugin controller inhertis from dashboard controller
    # and check_terms_of_use method is called on every request.
    # In order to reduce api calls we cache the result of new_user?
    # in the session for 5 minutes.

    # is_cache_expired = current_user.id!=session[:last_user_id] ||
    #   session[:last_request_timestamp].nil? ||
    #   (session[:last_request_timestamp] < Time.now-5.minute)
    #
    # if is_cache_expired
    #   session[:last_request_timestamp] = Time.now
    #   session[:last_user_id] = current_user.id
    #   session[:is_new_dashboard_user] = Dashboard::OnboardingService.new(service_user).new_user?(current_user)
    # end
    # session[:is_new_dashboard_user]
    Dashboard::OnboardingService.new(service_user).new_user?(current_user)
  end

  def reset_last_request_cache
    session[:last_request_timestamp]=nil
    session[:last_user_id]=nil
  end

  def set_mailer_host
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
    ActionMailer::Base.default_url_options[:protocol] = request.protocol
  end

end
