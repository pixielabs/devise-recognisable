module DeviseRecognisable
  autoload :Mailer, 'devise-recognisable/mailer'
end

module Devise
  module Recognisable
    class Error < StandardError; end
    require_relative "devise-recognisable/version"
    require_relative "devise-recognisable/engine"
  end
end

Devise.add_module :recognisable, model: 'devise-recognisable/model'
