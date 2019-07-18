module Devise
  module Models
    module Recognisable
      extend ActiveSupport::Concern

      # Send the 'New IP' email
      def send_new_ip_email
        token = generate_new_ip_token
        send_devise_notification(:new_ip, token, {})
      end

      protected

      def generate_new_ip_token
        # TODO: Can we use Devise's TokenGenerator?
        token = AuthenticationToken.encode(id: self.id)
        token
      end

      module ClassMethods

        def send_new_ip_email(attributes={})
          recognisable = find_or_initialize_with_errors([:email], attributes, :not_found)
          recognisable.send_new_ip_email if recognisable.persisted?
          recognisable
        end

      end
    end
  end
end
