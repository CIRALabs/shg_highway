# spec/requests/todos_spec.rb
require 'rails_helper'

RSpec.describe 'SmarKaKlink MASA API', type: :request do
  fixtures :all

  before(:each) do
    FileUtils::mkdir_p("tmp")
    HighwayKeys.ca.certdir = Rails.root.join('spec','files','cert')
    MasaKeys.masa.certdir = Rails.root.join('spec','files','cert')
    IDevIDKeys.ca.certdir = Rails.root.join('spec','files','cert')
  end

  describe "smarkaklink IDevID enrollment" do
    it "POST a smartpledge voucher request, using correct content_type" do
      token = IO::read("spec/files/enroll1.json")

      post "/.well-known/est/smarkaklink", params: token, headers: {
             'CONTENT_TYPE' => 'application/json',
             'ACCEPT'       => 'application/pkcs7',
           }

      expect(response).to have_http_status(200)
      owner=assigns(:owner)
      expect(owner).to_not be_nil

      cert = OpenSSL::X509::Certificate.new(response.body)
      expect(cert.issuer.to_s).to eq("/DC=ca/DC=sandelman/CN=highway-test.example.com IDevID CA")
      expect(cert.subject.to_s).to include(owner.simplename)
    end

    it "POST a smarkaklink voucher request, with an invalid content_type" do
      token = IO::read("spec/files/enroll1.json")

      post "/.well-known/est/smarkaklink", params: token, headers: {
             'CONTENT_TYPE' => 'application/pkcs10',
             'ACCEPT'       => 'application/pkcs7',
           }

      expect(response).to have_http_status(406)
      expect(assigns(:owner)).to be_nil
    end
  end

  describe "provision of a new device" do
    it "should provision a new device when mac address already loaded" do
      provision1 = IO::read("spec/files/hera.provision.json")

      post "/shg-provision", params: provision1, headers: {
             'CONTENT_TYPE' => 'application/json',
             'ACCEPT'       => 'application/tgz',
           }
      expect(response).to have_http_status(200)
      device = assigns(:device)
      expect(device).to eq(devices(:heranew))
    end

    it "should refuse a device when no mac address can be found" do
      $TOFU_DEVICE_REGISTER=false
      token = '{ "wan-mac" : "11-22-ba-dd-ba-dd" }'
      post "/shg-provision", params: token, headers: {
             'CONTENT_TYPE' => 'application/json',
             'ACCEPT'       => 'application/tgz',
           }
      expect(response).to have_http_status(404)
      device = assigns(:device)
      expect(device).to be_nil
    end

    it "should refuse a device, but remember it when in TOFU mode" do
      $TOFU_DEVICE_REGISTER=true
      token = '{ "wan-mac" : "11-22-ba-dd-ba-dd" }'
      post "/shg-provision", params: token, headers: {
             'CONTENT_TYPE' => 'application/json',
             'ACCEPT'       => 'application/tgz',
           }
      expect(response).to have_http_status(404)
      device = assigns(:device)
      expect(device).to_not be_nil
      expect(device.eui64).to eq('11-22-ba-dd-ba-dd')
    end
  end

end
