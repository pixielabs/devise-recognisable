# Devise::Recognisable

devise-recognisable adds a risk-based authentication layer to Devise. It uses
information about the user’s login attempt to decide whether or not to
immediately grant access or first require the user to verify their login by
clicking a one-time link in an email.

## Requirements

You will need a Rails app with Devise successfully set up. See
[Devise's documentation](https://github.com/plataformatec/devise/) for help
setting up Devise.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'devise-recognisable'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install devise-recognisable

Once you have Devise set up, add the `recognisable` module to your user model:

<pre>
devise :database_authenticatable, :registerable, <b>:recognisable</b>
</pre>

And generate the RecognisableSessions table.

    $ rails generate devise_recognisable:install
    $ rails db:migrate

## Security level

You can configure the security level of DeviseRecognisable to `:strict`,
`:normal` or `:relaxed` (default: :normal).

`:strict` - requires users to sign in unless all the recognisable details of the
request match the previous signin.

`:normal` - requires users to sign in if more than 1 of the recognisable details
of the request match the previous signin.

`:relaxed` - requires users to sign in if more than 2 of the recognisable details
of the request match the previous signin.

To configure DeviseRecognisable's security level to `:relaxed`, you would need
to add the following line to your app's Devise initializer file,
`./config/initializers/devise.rb`.

```ruby
config.security_level = :relaxed
```

## Max IP address distance

One of the checks DeviseRecognise makes is the geographic distance between the
the IP address of the login request and the IP address of a previous login.
You can configure the `max_ip_distance` of DeviseRecognisable in miles
(default: 100).

To configure DeviseRecognisable's `max_ip_distance` to 50 miles, you would need
to add the following line to your app's Devise initializer file,
`./config/initializers/devise.rb`.

```ruby
config.max_ip_distance = 50
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Debug mode

We will want to report unrecognised request in `Debug` mode to the error_logger of your choice.

To run DeviseRecognisable in `debug` mode, you need to add the following line
to your app's Devise initializer file, `./config/initializers/devise.rb`.

```ruby
config.debug_mode = true
```

_N.B. `Debug` mode only works in a production environment, so to actually log the
output to the error logger, you will need to deploy your app._

## error_logger

Once you have installed and configured the error logger of your choice, in order to log the output,
you will need to configure the `Devise.error_logger` in `./config/initializers/devise.rb`.

See some examples below

```ruby
#   Rollbar

  require 'rollbar'

  send_debug_message = lambda do |info, error_message|
    Rollbar.debug(info, error_message)
  end

  config.error_logger = send_debug_message
```

```ruby
#  Bugsnag

require 'bugsnag'

send_debug_message = lambda do |info, error_message|
    Bugsnag.notify(info, error_message)
end

config.error_logger = send_debug_message
```

```ruby
# Sentry

require 'sentry-ruby'

send_debug_message = lambda do |info, error_message|
    Sentry.capture_exception(info, error_message)
end

config.error_logger = send_debug_message
```

## Info_only mode

You can run DeviseRecognisable in `info_only` mode which turns
devise_recongise __off__. In `info_only` mode, if devise_recognise does not
recognise the login request source, it logs the request details, but does not
require the user to click a link in their email.

If you are running
devise_recognisable in `info_only` mode, you will need to run `gem install rollbar`.

To run DeviseRecognisable in `info_only` mode, you need to add the following line
to your app's Devise initializer file, `./config/initializers/devise.rb`.

```ruby
config.info_only = true
```

## Deploying to Staging

If you want to deploy to staging, first merge your changes into the staging
branch and push them to github. Then run `bundle update` and commit the new
`Gemfile.lock`. Pushing the `Gemfile.lock` will trigger a deploy that includes
your latest changes.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/pixielabs/devise-recognisable. This project is intended to be
a safe, welcoming space for collaboration, and contributors are expected to
adhere to the [Contributor Covenant](http://contributor-covenant.org) code of
conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Devise::Recognisable project’s codebases, issue
trackers, chat rooms and mailing lists is expected to follow the
[code of conduct](https://github.com/pixielabs/devise-recognisable/blob/master/CODE_OF_CONDUCT.md).
