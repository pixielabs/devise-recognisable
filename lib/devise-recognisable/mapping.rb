module DeviseRecognisable
  module Mapping

    private

    def default_controllers(options)
      options[:controllers] ||= {}
      # Use our SessionsController instead of Devise's.
      options[:controllers][:sessions] ||= 'devise_recognisable/sessions'
      super
    end

  end
end
