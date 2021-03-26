class RemoveUrlFromContributions < ActiveRecord::Migration[6.1]
  def change
    remove_column :contributions, :url, :string
  end
end
