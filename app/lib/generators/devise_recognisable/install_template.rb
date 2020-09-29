class CreateRecognisableSessions < <%= migration_parent %>
  def change
    create_table :recognisable_sessions do |t|
      t.string :recognisable_type
      t.integer :recognisable_id
      t.string :sign_in_ip
      t.string :user_agent
      t.datetime :sign_in_at
    end
    add_index :recognisable_sessions, [:recognisable_type, :recognisable_id], :name => 'recognisable_index'
  end
end