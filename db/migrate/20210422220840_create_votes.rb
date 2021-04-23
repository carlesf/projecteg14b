class CreateVotes < ActiveRecord::Migration[6.1]
  def change
    create_table :votes do |t|
      t.integer :votable_id
      t.string :votable_type
      t.integer :voter_id

      t.timestamps
    end
  end
end
