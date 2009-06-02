class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :screen_name
      t.string :token
      t.string :secret

      t.timestamps
    end
    add_index :users, :screen_name, :unique => true
  end

  def self.down
    drop_table :users
  end
end
