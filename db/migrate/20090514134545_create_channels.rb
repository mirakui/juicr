class CreateChannels < ActiveRecord::Migration
  def self.up
    create_table :channels do |t|
      t.string :name
      t.string :description
      t.string :query
      t.string :keywords
      t.string :extract_users
      t.string :audiences
      t.integer :permission
      t.integer :search_engine
      t.integer :author_id
      t.string :alias
      t.boolean :editable

      t.timestamps
    end
    add_index :channels, :alias, :unique => true
  end

  def self.down
    drop_table :channels
  end
end
