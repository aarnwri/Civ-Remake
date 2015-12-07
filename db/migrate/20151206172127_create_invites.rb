class CreateInvites < ActiveRecord::Migration
  def change
    create_table :invites do |t|
      t.integer :user_id    # belongs_to User
      t.integer :game_id    # belongs_to Game

      t.boolean :received
      t.boolean :accepted
      t.boolean :rejected

      t.timestamps null: false
    end

    add_index :invites, :user_id
    add_index :invites, :game_id
    add_index :invites, [:user_id, :game_id], unique: true
  end
end
