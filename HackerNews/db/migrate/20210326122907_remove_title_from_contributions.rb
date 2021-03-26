class RemoveTitleFromContributions < ActiveRecord::Migration[6.1]
  def change
    remove_column :contributions, :title, :string
  end
end
