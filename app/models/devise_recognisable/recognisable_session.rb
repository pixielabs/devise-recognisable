class DeviseRecognisable::RecognisableSession < ApplicationRecord
  belongs_to :recognisable, :polymorphic => true
end