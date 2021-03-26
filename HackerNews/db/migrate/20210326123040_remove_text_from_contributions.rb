class RemoveTextFromContributions < ActiveRecord::Migration[6.1]
  def change
    remove_column :contributions, :text, :text
  end
end
