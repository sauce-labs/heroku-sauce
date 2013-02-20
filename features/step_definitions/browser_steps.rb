Given /^I haven't already configured the plugin$/ do
  # no op
end

Given /^I have configured the plugin$/ do
  dump_config!
end

And /^The ([\w_]+) environment variable is nil$/ do |env_name|
  ENV.stub(:[]).and_call_original
  ENV.stub(:[]).with(env_name) {nil}
end
