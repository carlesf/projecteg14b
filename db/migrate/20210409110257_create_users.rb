class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.text :about
      t.string :email

      t.timestamps
    end
  end
end
