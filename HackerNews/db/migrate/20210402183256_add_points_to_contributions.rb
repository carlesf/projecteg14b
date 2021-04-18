class AddPointsToContributions < ActiveRecord::Migration[6.1]
  def change
    add_column :contributions, :points, :integer, default: 0
  end
end
