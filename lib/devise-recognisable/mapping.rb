module DeviseRecognisable
  module Mapping

    private

    def default_controllers(options)
      options[:controllers] ||= {}
      # Use our SessionsController instead of Devise's.
      options[:controllers][:sessions] ||= 'devise_recognisable/sessions'
      options[:controllers][:registrations] ||= 'devise_recognisable/registrations'
      super
    end

  end
end
