class RemoveCommentReplyTypeFromReplies < ActiveRecord::Migration[6.1]
  def change
    remove_column :replies, :commentreply_type, :string
  end
end
