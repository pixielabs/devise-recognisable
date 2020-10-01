# Devise::Recognisable

devise-recognisable adds a risk-based authentication layer to Devise. It uses
information about the user’s login attempt to decide whether or not to
immediately grant access or first require the user to verify their login by
clicking a one-time link in an email.

## Requirements

You will need a Rails app with Devise successfully set up. See
[Devise's documentation](https://github.com/plataformatec/devise/) for help
setting up Devise.

You also need the [trackable module](https://www.rubydoc.info/github/plataformatec/devise/master/Devise/Models/Trackable)
if you haven’t already got that. Devise have [instructions for adding trackable to users](https://github.com/plataformatec/devise/wiki/How-To:-Add-:trackable-to-Users).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'devise-recognisable'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install devise-recognisable

Once you have Devise and `trackable` set up, add the `recognisable` module to your
user model:

<pre>
devise :database_authenticatable, :registerable, :trackable, <b>:recognisable</b>
</pre>

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

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
