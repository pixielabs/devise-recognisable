class CreateRecognisableSessions < <%= "ActiveRecord::Migration[#{ActiveRecord::Migration.current_version}]" %>
  def change
    create_table :recognisable_sessions do |t|
      t.string  :recognisable_type
      t.integer :recognisable_id
      t.<%= ip_column %> :sign_in_ip
      t.datetime  :sign_in_at
    end
    add_index :recognisable_sessions, [:recognisable_type, :recognisable_id], :name => 'recognisable_index'
  end
end
