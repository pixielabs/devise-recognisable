class Engine < Rails::Engine

  # We use to_prepare instead of after_initialize here because Devise is a Rails
  # engine; its mailer is reloaded like the rest of the user's app.
  # Got to make sure that our mailer methods are included each time Devise.mailer
  # is (re)loaded.
  config.to_prepare do
    Devise.mailer.send :include, DeviseRecognisable::Mailer
    unless Devise.mailer.ancestors.include?(Devise::Mailers::Helpers)
      Devise.mailer.send :include, Devise::Mailers::Helpers
    end
  end

  # Extend mapping with after_initialize because it's not reloaded. This is so
  # we can use our SessionsController instead of Devise's one.
  config.after_initialize do
    Devise::Mapping.send :prepend, DeviseRecognisable::Mapping
  end

end
