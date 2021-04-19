class AddUserToContributions < ActiveRecord::Migration[6.1]
  def change
    add_column :contributions, :user, :string
  end
end
