require "rspec"
require "spec_helper"
require "sauce/rest_api/rest_api"

describe RestAPI do

  describe "#get_user_details" do
    let(:user_details) {
      {
          access_key:     "1212-12rvetbrbr-4f43vetvetv",
          minutes:        150,
          id:             "demo-faker",
          subscribed:     true,
          can_run_manual: true
      }
    }

    before(:each) do
      @response = double()
      @response.stub(:body) {user_details.to_json}
      @response.stub(:code) {200}
    end

    it "calls the API with credentials" do
      expected_url = "https://saucelabs.com/rest/v1/users"
      expected_options = {:basic_auth => {:username => "un", :password => "pw"}}
      HTTParty.should_receive(:get).with(expected_url, expected_options){@response}
      RestAPI.get_user_details("un", "pw")
    end

    context "with valid authentication" do


      it "should parse the result" do
        HTTParty.stub(:get => @response)
        RestAPI.get_user_details("un", "pw").should eq user_details
      end

    end

    context "with invalid authentication" do
      before(:each) do
        @response = double()
        @response.stub(:code) {401}
        @response.stub(:body) {{:error => "Invalid login credentials"}.to_json}
      end

      it "should return an error" do
        HTTParty.stub(:get => @response)
        expect {RestAPI.get_user_details("un" , "pw")}.to raise_error Sauce::AuthenticationError
      end

    end

  end
end