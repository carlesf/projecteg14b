class AddContentToContributions < ActiveRecord::Migration[6.1]
  def change
    add_column :contributions, :content, :text
  end
end
