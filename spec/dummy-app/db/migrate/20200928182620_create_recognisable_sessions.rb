class CreateRecognisableSessions < ActiveRecord::Migration[5.2]
  def change
    create_table :recognisable_sessions do |t|
      t.references :recognisable, polymorphic: true
      t.string :sign_in_ip
      t.datetime :sign_in_at
    end
  end
end
