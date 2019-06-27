require 'rails'

module Devise
  module Recognisable
    class Error < StandardError; end
    require_relative "devise-recognisable/version"
    require_relative "devise-recognisable/engine"
  end
end
