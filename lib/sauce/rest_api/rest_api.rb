require "httparty"
require "sauce/rest_api/exceptions"

class RestAPI

  @api_root = "https://saucelabs.com/rest/v1/users"

  def self.get_user_details(username, password)
    auth = {:username => username, :password => password}
    response = HTTParty.get(@api_root, :basic_auth => auth)

    case response.code
      when 401
        raise Sauce::AuthenticationError.new
      else
        JSON.parse(response.body, :symbolize_names => true)
    end
  end
end