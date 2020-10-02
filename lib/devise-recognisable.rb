require 'devise'

module DeviseRecognisable
  autoload :Mailer, 'devise-recognisable/mailer'
  autoload :Mapping, 'devise-recognisable/mapping'
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

  # Public: Security level set the strictness of Devise Recognisable (default: :normal).
  # :strict  requires users to sign in unless all the recognisable details of
  #          the request match the previous signin.
  # :normal  requires users to sign in if more than 1 of the recognisable
  #          details of the request match the previous signin.
  # :relaxed requires users to sign in if more than 2 of the recognisable
  #          details of the request match the previous signin.
  #
  # Set this in the Devise configuration file (in config/initializers/devise.rb).
  #
  #   config.security_level = :strict
  mattr_accessor :security_level
  @@security_level = :normal

  # Debug: Debug mode. When a request's features aren't recognised, we write
  # the request details to a logs file. This should __not__ be set to true in
  # production.
  mattr_accessor :debug_mode
  @@debug_mode = false
end

Devise.add_module :recognisable, model: 'devise-recognisable/model'
