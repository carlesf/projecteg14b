class AddTipusToContributions < ActiveRecord::Migration[6.1]
  def change
    add_column :contributions, :tipus, :string
  end
end
