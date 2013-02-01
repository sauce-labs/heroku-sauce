require 'yaml'
require 'sauce/rest_api/rest_api'

module Sauce
  module Heroku
    class Config
      CONFIG_FILE = 'ondemand.yml'
      attr_accessor :config

      def filepath
        [
          File.join(Dir.pwd, CONFIG_FILE),
          File.expand_path("~/.sauce/#{CONFIG_FILE}")
        ].each do |path|
          if File.exists?(path)
            return path
          end
        end
        return nil
      end

      def load!
        return config unless config.nil?
        return nil if filepath.nil?

        @config = YAML.load_file(filepath)
      end

      def configured?
        configuration_present = !(config.nil?)
        unless !configuration_present
          environment_configuration = ENV["SAUCE_USERNAME"] && ENV["SAUCE_ACCESS_KEY"]
          if environment_configuration
            puts "Warning: No configuration detected, using environment variables instead"
            configuration_present = true
          end
        end
        return configuration_present
      end

      def guess_config (password)
        username = ::Heroku::Auth.user
        user_details = RestAPI.get_user_details username, password

        @config = {}

        puts "USAR:  #{user_details}"
        config['username'] = user_details[:id]
        config['access_key'] = user_details[:access_key]

        return user_details[:id], user_details[:access_key]
      end

      def username
        if !configured?
          return ENV["SAUCE_USERNAME"]
        end
        config['username']
      end

      def access_key
        if !configured?
          return ENV["SAUCE_ACCESS_KEY"]
        end
        config['access_key']
      end

      def write!
        if username.nil? || access_key.nil?
          return nil
        end
      end
    end
  end
end
