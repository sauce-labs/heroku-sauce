#ENV Stubbing is being weird

Around('@remove_environment_variables') do |scenario, block|
  @env_username = ENV["SAUCE_USERNAME"]
  @env_access_key = ENV["SAUCE_ACCESS_KEY"]

  ENV.delete "SAUCE_USERNAME"
  ENV.delete "SAUCE_ACCESS_KEY"

  block.call

  unless @env_username.nil?
    ENV["SAUCE_USERNAME"] = @env_username
  end
  unless @env_access_key.nil?
    ENV["SAUCE_ACCESS_KEY"] = @env_access_key
  end
end

Around('@set_environment_variables') do |scenario, block|
  @env_username = ENV["SAUCE_USERNAME"]
  @env_access_key = ENV["SAUCE_ACCESS_KEY"]

  ENV["SAUCE_USERNAME"] = "cool_user"
  ENV["SAUCE_ACCESS_KEY"] = "DEDEDED"

  block.call

  unless @env_username.nil?
    ENV["SAUCE_USERNAME"] = @env_username
  else
    ENV.delete "SAUCE_USERNAME"
  end
  unless @env_access_key.nil?
    ENV["SAUCE_ACCESS_KEY"] = @env_access_key
  else
    ENV.delete "SAUCE_ACCESS_KEY"
  end
end
