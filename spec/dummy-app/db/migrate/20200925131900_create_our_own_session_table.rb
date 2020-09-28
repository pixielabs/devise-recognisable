class CreateOurOwnSessionTable < ActiveRecord::Migration[5.2]
  def up
    remove_columns :users, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip
    
    create_table :recognisable_sessions
    add_reference :recognisable_sessions, :user
    add_column :recognisable_sessions, :sign_in_ip, :string
    add_column :recognisable_sessions, :sign_in_at, :datetime
  end

  def down
    drop_table :recognisable_sessions
    
    add_column :users, :sign_in_count, :integer, default: 0, null: false
    add_column :users, :current_sign_in_at, :datetime
    add_column :users, :last_sign_in_at, :datetime
    add_column :users, :current_sign_in_ip, :inet
    add_column :users, :last_sign_in_ip, :inet
  end
end
