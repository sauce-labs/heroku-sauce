require 'spec_helper'
require "sauce/rest_api/rest_api"
require "heroku/auth"

describe Sauce::Heroku::Config do
  let(:config) { described_class.new }

  describe '#config' do
    subject { config.config }
    context 'by default' do
      it { should be_nil }
    end
  end

  describe '#guess_config' do

    before(:each) do
      RestAPI.stub(:get_user_details) {{:id => "someguy", :access_key => "access_key"}}
    end

    it "calls the API with the Heroku username and password" do
      password = "dsfargeg"
      RestAPI.should_receive(:get_user_details).with(Heroku::Auth.user, password)
      config.guess_config(password)
    end

    it "stores the details if they're found" do
      config.guess_config("")

      config.username.should eq "someguy"
      config.access_key.should eq "access_key"
    end

  end

  describe '#configured?' do
    subject { config.configured? }

    context 'by default' do
      it { should_not be_true }
    end

    context 'when a config has been loaded' do
      before :each do
        config.stub(:config => {})
      end

      it { should be_true }
    end
  end

  describe '#authentication_available?' do
    subject { config.authentication_available? }
    context 'without config details but partial env vars' do

      before :each do
        config.stub(:config => nil)
        @stored_username = ENV["SAUCE_USERNAME"]
        @stored_access_key = ENV["SAUCE_ACCESS_KEY"]
        ENV.delete "SAUCE_USERNAME"
        ENV["SAUCE_ACCESS_KEY"] = "SFDFDSFSDFSDF"
      end

      after :each do
        unless @stored_username.nil?
          ENV["SAUCE_USERNAME"] = @stored_username
        end

        unless @stored_access_key.nil?
          ENV["SAUCE_ACCESS_KEY"] = @stored_access_key
        end
      end

      it { subject.should be_false }
    end

    context 'without config details, but env vars' do
      before :each do
        config.stub(:config => nil)
      end

      before :all do
        @stored_username = ENV["SAUCE_USERNAME"]
        @stored_access_key = ENV["STORED_ACCESS_KEY"]

        ENV["SAUCE_USERNAME"] = "lollipop"
        ENV["SAUCE_ACCESS_KEY"] = "dsfas343"
      end

      after :all do
        ENV["SAUCE_USERNAME"] = @stored_username
        ENV["SAUCE_ACCESS_KEY"] = @stored_access_key
      end

      it {should be_true}

      it "should output a warning message" do
        config.should_receive(:puts).with 'Warning: No configuration detected, using environment variables instead'
        config.authentication_available?
      end
    end
  end

  describe '#environment_configured?' do
    subject { config.environment_configured?}

    context "with env vars" do
      before (:each) do
        ENV.stub(:[]).with("SAUCE_USERNAME") { "DERPS" }
        ENV.stub(:[]).with("SAUCE_ACCESS_KEY") { "HERPS" }
      end

      it {should be_true}
    end

    context "without env vars" do
      before (:each) do
        ENV.stub(:[]).with("SAUCE_USERNAME") {nil}
        ENV.stub(:[]).with("SAUCE_ACCESS_KEY") {nil}
      end

      it {should be_false}
    end

    context "only username" do
      before (:each) do
        ENV.stub(:[]).with("SAUCE_USERNAME") { "DERPS" }
        ENV.stub(:[]).with("SAUCE_ACCESS_KEY") {nil}
      end

      it {should be_false}
    end
  end

  describe '#load!' do
    subject { config.load! }

    context 'when no config files are available' do
      before :each do
        puts "Config is currently: #{config.nil?}"
        config.should_receive(:filepath)
      end
      
      context 'with no environment variables' do
        before :each do
          config.stub(:environment_configured?).and_return {false}
        end
        it { should be_nil }
      end
    end

    context 'when a config file is available' do
      let(:fakepath) { '//fake/path/ondemand.yml' }
      let(:contents) { {'config' => true} }

      before :each do
        config.stub(:filepath => fakepath)
        YAML.should_receive(:load_file).with(fakepath).and_return(contents)
      end

      it { should eql(contents) }
    end

    context 'when a config has already been loaded' do
      let(:contents) { {'config' => true} }

      before :each do
        config.stub(:config => contents)
        config.should_receive(:filepath).never
        YAML.should_receive(:load_file).never
      end

      it { should eql(contents) }
    end
  end

  describe '#filepath' do
    subject { config.filepath }

    context 'when no config files exist' do
      before :each do
        File.stub(:exists?).and_return(false)
      end

      it { should be_nil }
    end

    context 'when a local config file exists' do
      let(:expected_path) { File.join(Dir.pwd, Sauce::Heroku::Config::CONFIG_FILE) }

      before :each do
        File.should_receive(:exists?).with(expected_path).and_return(true)
      end

      it { should eql(expected_path) }
    end

    context 'when a user config file exists' do
      let(:expected_path) do
        File.expand_path("~/.sauce/#{Sauce::Heroku::Config::CONFIG_FILE}")
      end

      before :each do
        local_path = File.join(Dir.pwd, Sauce::Heroku::Config::CONFIG_FILE)
        File.should_receive(:exists?).with(local_path).and_return(false)
        File.should_receive(:exists?).with(expected_path).and_return(true)
      end

      it { should eql(expected_path) }
    end
  end

  describe '#username' do
    subject { config.username }

    context 'when not configured' do
      before :each do
        config.stub(:configured? => false)
        @stored_username = ENV["SAUCE_USERNAME"]
      end

      after :each do
        if @stored_username
          ENV["SAUCE_USERNAME"] = @stored_username
        else
          ENV.delete "SAUCE_USERNAME"
        end
      end

      context "without ENV details" do
        before :each do
          ENV.delete "SAUCE_USERNAME"
        end

        it { should be_nil }
      end

      context "with details in the ENV" do
        before :each do
          ENV["SAUCE_USERNAME"] = 'duckling'
        end

        it {should eq 'duckling'}
      end
    end

    context 'when configured' do
      let(:username) { 'rspec' }
      let(:contents) { {'username' => username } }
      before :each do
        config.stub(:config => contents)
      end

      it { should eql(username) }
    end
  end

  describe '#access_key' do
    subject { config.access_key }

    context 'when not configured' do
      before :each do
        config.stub(:configured? => false)
        @stored_access_key = ENV["SAUCE_ACCESS_KEY"]
      end

      after :each do
        if @stored_access_key
          ENV["SAUCE_ACCESS_KEY"] = @stored_access_key
        else
          ENV.delete "SAUCE_ACCESS_KEY"
        end
      end

      context "without ENV variables" do
        before :each do
          ENV.delete "SAUCE_ACCESS_KEY"
        end

        it { should be_nil }
      end
      
      context "with details in the ENV" do
        before :each do
          ENV["SAUCE_ACCESS_KEY"] = 'DSFARGEG'
        end

        it {should eq 'DSFARGEG'}
      end
    end

    context 'when configured' do
      let(:key) { 'spec-key' }
      let(:contents) { {'access_key' => key } }
      before :each do
        config.stub(:config => contents)
      end

      it { should eql(key) }
    end
  end

  describe '#write!' do
  end
end
