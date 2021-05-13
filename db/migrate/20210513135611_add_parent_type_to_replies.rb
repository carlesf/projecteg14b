class AddParentTypeToReplies < ActiveRecord::Migration[6.1]
  def change
    add_column :replies, :parent_type, :boolean
  end
end
