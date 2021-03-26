class AddTypeToContributions < ActiveRecord::Migration[6.1]
  def change
    add_column :contributions, :type, :string
  end
end
