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
        if filepath.nil?
          if environment_configured?
            puts "Warning: No configuration detected, using environment variables instead"
            return @config = {
                "username" => env_username, 
                "access_key" => env_access_key
            }
          else
            return nil
          end
        end
        @config = YAML.load_file(filepath)
      end

      def configured?
        !(config.nil?)
      end

      def authentication_available?
        auth_available = configured?
        if !auth_available
          if environment_configured?
            puts "Warning: No configuration detected, using environment variables instead"
            auth_available = true
          end
        end
        auth_available
      end

      def environment_configured?
        !(env_access_key.nil? || env_username.nil?)
      end

      def guess_config (password)
        username = ::Heroku::Auth.user
        user_details = RestAPI.get_user_details username, password

        @config = {}

        puts "Checking: #{username} #{password} - #{user_details}"
        config['username'] = user_details[:id]
        config['access_key'] = user_details[:access_key]

        return [user_details[:id], user_details[:access_key]]
      end

      def username
        !config.nil? ? config['username'] : nil || env_username
      end

      def env_username
        ENV["SAUCE_USERNAME"]
      end

      def access_key  
        !config.nil? ? config['access_key'] : nil || env_access_key
      end

      def env_access_key
        ENV["SAUCE_ACCESS_KEY"]
      end

      def write!
        if username.nil? || access_key.nil?
          return nil
        end
      end
    end
  end
end
