module DeviseRecognisable
  autoload :Mailer, 'devise-recognisable/mailer'
end

module Devise
  class Error < StandardError; end
  require_relative "devise-recognisable/engine"

  # Public: Max distance in miles allowed between the last sign in IP address
  # and the current sign in attempt (default: 100 miles).
  #
  # Set this in the Devise configuration file (in config/initializers/devise.rb).
  #
  #   config.max_ip_distance = 50 # => Sign in attempts from IPs further than
  #   50 miles from the last signin will need to log in via email.
  mattr_accessor :max_ip_distance
  @@max_ip_distance = 100

end

Devise.add_module :recognisable, model: 'devise-recognisable/model'
