Feature: Start a firefox browser pointing at my Heroku site
  In order to test my website in the Firefox browser
  As a Heroku user
  I should be able to fire up a Sauce Scout instance pointing at my Heroku
  instance

  @remove_environment_variables
  Scenario: Without having configured Sauce
    Given I haven't already configured the plugin
    When I run `heroku sauce:firefox`
    Then the output should contain:
      """
      Sauce for Heroku has not yet been configured!
      """
  Scenario: With Sauce configured, there is no use of ENV VARS
    Given I have configured the plugin
    When I run `heroku sauce:firefox`
    Then the output should not contain: 
    """
    Warning: No configuration detected, using environment variables instead
    """
  
  @set_environment_variables
  Scenario: Without having configured Sauce
    Given I haven't already configured the plugin
    When I run `heroku sauce:firefox`
    Then the output should contain:
      """
      Warning: No configuration detected, using environment variables instead
      """
  @wip
  Scenario: With Sauce configured
    Given I have configured the plugin
    When I run `heroku sauce:firefox`
    Then the output should contain:
      """
      Starting a Chrome session!
      """
