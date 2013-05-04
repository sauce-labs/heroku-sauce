# Heroku + Sauce = ♡

An experimental plugin for the Heroku CLI to hook it up to Sauce Labs.


## Using

To install the Sauce for Heroku plugin, run the following command:

    % heroku plugins:install git://github.com/sauce-labs/heroku-sauce.git

After the plugin has been successfully installed, the `heroku help sauce`
command should list a number of available subcommands:

    % heroku help sauce
    Usage: heroku sauce


    Additional commands, type "heroku help COMMAND" for more details:

    sauce:android    # 
    sauce:configure  #  Configure the Sauce CLI plugin using your heroku email and Sauce Labs password
    sauce:firefox    # 
    sauce:firefox4   # 
    sauce:ie6        # 
    sauce:ie7        # 
    sauce:ie8        # 
    sauce:ie9        # 
    sauce:iphone     # 
    sauce:safari     # 

    %


If you do not have a Sauce Labs account, you can [register here](https://saucelabs.com/signup/plan/free).


Once you have an account, use the following command to configure Heroku for
Sauce:

    % heroku sauce:configure
    Password for Sauce Labs:

    Sauce CLI plugin configured with:
 
    Username: example
    API key : example-key

If you don't use the same email for heroku as your sauce labs account, you can supply your credentials on the commandline:

    % heroku sauce:configure -u <sauce username> -k <sauce access key>
    
    Sauce CLI plugin configured with:

    Username: example
    API key : example-api-key

    If you would like to change this later, update "ondemand.yml" in your current directory
    %


Hooray! Sauce for Heroku is now configured! Running one of the other commands,
such as `heroku sauce:firefox` will open your browser with a Firefox browser
running on Sauce, hitting your Heroku app.

Happy testing!
