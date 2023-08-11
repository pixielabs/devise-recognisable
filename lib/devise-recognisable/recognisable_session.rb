class DeviseRecognisable::RecognisableSession < ActiveRecord::Base
  belongs_to :recognisable, :polymorphic => true
end
