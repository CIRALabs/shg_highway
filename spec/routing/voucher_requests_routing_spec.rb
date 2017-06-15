require "rails_helper"

RSpec.describe VoucherRequestsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/voucher_requests").to route_to("voucher_requests#index")
    end

    it "routes to #new" do
      expect(:get => "/voucher_requests/new").to route_to("voucher_requests#new")
    end

    it "routes to #show" do
      expect(:get => "/voucher_requests/1").to route_to("voucher_requests#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/voucher_requests/1/edit").to route_to("voucher_requests#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/voucher_requests").to route_to("voucher_requests#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/voucher_requests/1").to route_to("voucher_requests#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/voucher_requests/1").to route_to("voucher_requests#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/voucher_requests/1").to route_to("voucher_requests#destroy", :id => "1")
    end

  end
end
