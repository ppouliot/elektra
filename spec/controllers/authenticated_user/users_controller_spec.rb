require 'spec_helper'
# require 'controllers/authenticated_user/shared_examples'

describe AuthenticatedUser::UsersController do
  include AuthenticationStub

  # commented out for now because the user controller doesn't have an index action and all the shared examples use the index action
  # it_behaves_like "an authenticated_user controller"
  default_params = {domain_id: AuthenticationStub.domain_id}

  before(:each) do
    stub_authentication

    driver = object_spy('driver')
    allow_any_instance_of(Openstack::IdentityService).to receive(:driver).and_return(driver)
  end

  describe "GET 'new'" do
    it "returns http success" do
      get :new, default_params
      expect(response).to be_success
    end
  end

end
